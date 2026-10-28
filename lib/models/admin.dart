import 'customer.dart';

class Admin extends Customer {
  Admin({
    required super.email,
    required super.password,
  });

  void deleteRegisteredUser(String customerName) {
    // TODO: implement deleteRegisteredUser
  }

  String lookUpOrderNumber(String orderNumber) {
    // TODO: implement lookUpOrderNumber
    return '';
  }

  void modifyPrice() {
    // TODO: implement modifyPrice
  }

  void modifySpecifications() {
    // TODO: implement modifySpecifications
  }

  void addProduct(
    int printerID,
    double price,
    String specs,
    int stock,
    String category,
  ) {
    // TODO: implement addProduct
  }

  void deleteProduct(int printerID) {
    // TODO: implement deleteProduct
  }
}
