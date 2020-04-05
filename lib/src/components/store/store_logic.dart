import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rxdart/subjects.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';

class StoreLogic implements BlocBase {
  final AuthLogic authLogic;
  final RepositoryManager repo = Repo.instance;
  // product details about consumable purchases from in_app_purchases
  List<ProductDetails> _productDetails;
  // product details about subscriptions from purchases_flutter
  Offering _offering;

  StreamController<StoreEvent> _inputController =
      StreamController<StoreEvent>();

  BehaviorSubject<StoreState> _outputController = BehaviorSubject<StoreState>();
  Stream<StoreState> get storeState => _outputController.stream;

  StreamController<String> _errorController = StreamController<String>.broadcast();
  Stream<String> get storeError => _errorController.stream;
  void addError(String error) => _errorController.sink.add(error);

  InAppPurchaseConnection get iap => InAppPurchaseConnection.instance;

  StoreLogic({this.authLogic}) {
    assert(authLogic != null);
    _outputController.sink.add(StoreLoading());
    _inputController.stream.listen(_mapEventToState);
    iap.purchaseUpdatedStream.listen(_handlePurchases);

    _getStoreInfo();
    _initPurchaserState();
  }

  Future<void> _initPurchaserState() async {
    Purchases.setDebugLogsEnabled(true);
    try {
      await Purchases.setup("yvCKwcjywCNXhXfOvWtAxECzCQDrvlOJ",
          appUserId: authLogic.token);
    } catch (e) {
      addError('error in setup: $e');
    }
    Purchases.addPurchaserInfoUpdateListener(_setPurchases);
    _getSubscriptionInfo();
  }

  void _setPurchases(PurchaserInfo info){
    if(info.entitlements.active.containsKey('Pro')){
      authLogic.setUserAsPro();
      _inputController.sink.add(InfoRetrieved());
    }
  }

  Future<void> _getSubscriptionInfo() async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      bool isPro = purchaserInfo.entitlements.active.containsKey('Pro');

      if (isPro) {
        authLogic.setUserAsPro();
      }

      Offerings offerings = await Purchases.getOfferings();

      if(offerings.current == null){
        addError('Problem Retrieving Current Offerings');
      }

      _offering = offerings.current;

      _inputController.sink.add(InfoRetrieved());
    } catch (e) {
      addError('Error in getSubscriptionInfo: $e');
    }
  }

  void _getStoreInfo() async {
    bool connected = await iap.isAvailable();
    if (!connected) {
      _outputController.sink.add(StoreUnavailable());
    } else {
      Set<String> ids = {
        'three_ampersands',
        'ten_ampersands',
      };
      _productDetails = await iap
          .queryProductDetails(ids)
          .then((response) => response.productDetails);

      _inputController.sink.add(InfoRetrieved());
    }
  }

  void _handlePurchases(List<PurchaseDetails> details) {
    details.forEach((purchaseDetail) async {
      if (purchaseDetail.status == PurchaseStatus.pending) {
        _outputController.sink.add(PurchasePending());
      }

      if (purchaseDetail.status == PurchaseStatus.purchased) {
        if (purchaseDetail.productID == 'three_ampersands') {
          await repo.incrementAmpersands(authLogic.token, 3);
          iap.completePurchase(purchaseDetail);
        }
        if (purchaseDetail.productID == 'ten_ampersands') {
          await repo.incrementAmpersands(authLogic.token, 12);
          iap.completePurchase(purchaseDetail);
        }
      }
      if (purchaseDetail.status == PurchaseStatus.error) {
        // show error
        addError(purchaseDetail.error.message);
        iap.completePurchase(purchaseDetail);
      }
    });
  }

  void _mapEventToState(StoreEvent event) async {
    if (event is InfoRetrieved) {
      if (_offering != null && _productDetails != null) {
        _outputController.sink.add(StoreLoaded(offering: _offering));
      }
    }
  }

  @override
  void dispose() {
    _inputController.close();
    _outputController.close();
    _errorController.close();
  }

  void buyThree() {
    iap.buyConsumable(
        purchaseParam: PurchaseParam(
            productDetails: _productDetails
                .firstWhere((element) => element.id == 'three_ampersands')));
  }

  void buyTwelve() {
    iap.buyConsumable(
        purchaseParam: PurchaseParam(
            productDetails: _productDetails
                .firstWhere((element) => element.id == 'ten_ampersands')));
  }

  void subscribeMonth() async {
    try {
      PurchaserInfo info = await Purchases.purchasePackage(_offering.monthly);
    } catch (e) {
      addError('$e');
    }
  }

  void subscribeYear() async {
    try {
      PurchaserInfo info = await Purchases.purchasePackage(_offering.annual);
    } catch (e) {
      addError('$e');
    }
  }

  void restorePurchases() async {
    try{
      PurchaserInfo info = await Purchases.restoreTransactions();
    } catch (e) {
      addError('$e');
    }
  }
}

class StoreEvent {}

class InfoRetrieved extends StoreEvent {}

class StoreState {}

class StoreLoading extends StoreState {}

class StoreUnavailable extends StoreState {}

class StoreLoaded extends StoreState {
  final Offering offering;
  StoreLoaded({this.offering});
}

class PurchasePending extends StoreLoaded {}
