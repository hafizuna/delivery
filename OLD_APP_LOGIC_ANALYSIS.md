# 🔍 OLD APP LOGIC ANALYSIS - COMPLETE BREAKDOWN

**Purpose:** Understand exactly how the old Firebase app works so we can replicate the same logic with Node.js

---

## 📦 CART SYSTEM LOGIC

### How Cart Works (OLD - Firebase)

#### 1. **Cart Storage**
```dart
// Uses SQLite local database (not Firestore!)
DatabaseHelper.instance.fetchCartProducts()  // Get cart from local DB
DatabaseHelper.instance.insertCartProduct()  // Add to local DB
DatabaseHelper.instance.updateCartProduct()  // Update local DB
DatabaseHelper.instance.deleteCartProduct()  // Remove from local DB
```

**Key Insight:** ✅ Cart is stored LOCALLY in SQLite, not in Firebase!

#### 2. **Cart Provider (Stream-based)**
```dart
class CartProvider {
  final _cartStreamController = StreamController<List<CartProductModel>>.broadcast();
  Stream<List<CartProductModel>> get cartStream => _cartStreamController.stream;
  
  // Cart operations update the stream
  addToCart() → Update DB → Emit stream event
  removeFromCart() → Update DB → Emit stream event
}
```

**Logic:**
1. Cart stored in local SQLite database
2. CartProvider wraps database with Stream
3. Controllers listen to cart stream
4. UI updates automatically when cart changes

#### 3. **Add to Cart Logic**
```dart
addToCart(product, quantity) {
  // Check if product already in cart
  if (product exists in cart) {
    // Update quantity and extras
    cart[index].quantity = quantity;
    cart[index].extras = product.extras;
    DatabaseHelper.updateCartProduct();
  } else {
    // Check if cart is empty OR same vendor
    if (cart.isEmpty || cart has same vendorID) {
      // Add product
      cart.add(product);
      DatabaseHelper.insertCartProduct();
    } else {
      // Different vendor - show dialog
      showDialog("Replace cart with new vendor?");
      if (user clicks "Add") {
        // Clear cart and add new product
        cart.clear();
        DatabaseHelper.deleteAllCartProducts();
        addToCart(product, quantity);
      }
    }
  }
  // Emit stream event
  _cartStreamController.sink.add(cart);
}
```

**Business Rules:**
- ✅ Can only have items from ONE vendor at a time
- ✅ If adding from different vendor, must clear cart first
- ✅ Shows confirmation dialog before clearing
- ✅ Quantity updates replace existing quantity (not add)
- ✅ Extras are updated when quantity changes

#### 4. **Cart Price Calculation**
```dart
calculatePrice() {
  // Reset all values
  deliveryCharges = 0.0;
  subTotal = 0.0;
  couponAmount = 0.0;
  specialDiscountAmount = 0.0;
  taxAmount = 0.0;
  totalAmount = 0.0;
  
  // 1. Calculate delivery charges (if delivery type)
  if (selectedFoodType == "Delivery") {
    // Calculate distance
    totalDistance = getDistance(customerAddress, vendorAddress);
    
    // Check if vendor can modify delivery charge
    if (deliveryChargeModel.vendorCanModify == false) {
      // Use global delivery charge
      if (totalDistance > minimumKm) {
        deliveryCharges = totalDistance * perKmCharge;
      } else {
        deliveryCharges = minimumCharge;
      }
    } else {
      // Use vendor-specific delivery charge
      if (vendor has custom delivery charge) {
        // Use vendor's rates
      } else {
        // Fall back to global rates
      }
    }
  }
  
  // 2. Calculate subtotal
  for (each item in cart) {
    if (item has discount price) {
      subTotal += (discountPrice * quantity) + (extrasPrice * quantity);
    } else {
      subTotal += (price * quantity) + (extrasPrice * quantity);
    }
  }
  
  // 3. Apply coupon discount
  if (coupon selected) {
    if (coupon.type == "percentage") {
      couponAmount = subTotal * coupon.discount / 100;
    } else {
      couponAmount = coupon.discount;
    }
  }
  
  // 4. Apply special discount (time-based)
  if (vendor.specialDiscountEnable && current time in discount window) {
    if (discount.type == "percentage") {
      specialDiscountAmount = subTotal * discount / 100;
    } else {
      specialDiscountAmount = discount;
    }
  }
  
  // 5. Calculate tax
  for (each tax in taxList) {
    taxableAmount = subTotal - couponAmount - specialDiscountAmount;
    if (tax.type == "percentage") {
      taxAmount += taxableAmount * tax.value / 100;
    } else {
      taxAmount += tax.value;
    }
  }
  
  // 6. Calculate total
  totalAmount = (subTotal - couponAmount - specialDiscountAmount) 
                + taxAmount 
                + deliveryCharges 
                + deliveryTips;
}
```

**Calculation Order:**
1. Subtotal (items + extras)
2. Coupon discount
3. Special discount (time-based)
4. Tax (on discounted amount)
5. Delivery charges
6. Tips
7. **Final Total**

---

## 📦 ORDER PLACEMENT LOGIC

### How Order Placement Works

#### 1. **Place Order Flow**
```dart
placeOrder() {
  // 1. Check payment method
  if (paymentMethod == "wallet") {
    if (walletBalance >= totalAmount) {
      setOrder();  // Proceed
    } else {
      showError("Insufficient balance");
    }
  } else {
    setOrder();  // Proceed with other payment
  }
}
```

#### 2. **Set Order Logic**
```dart
setOrder() async {
  ShowLoader();
  
  // 1. Check vendor subscription (if applicable)
  if (subscription model enabled) {
    vendor = getVendorById();
    if (vendor.subscriptionTotalOrders == '0') {
      showError("Vendor reached max orders");
      return;
    }
  }
  
  // 2. Prepare cart products
  for (each cartProduct in cart) {
    if (cartProduct.extrasPrice == '0') {
      cartProduct.extras = [];  // Remove empty extras
    }
    tempProducts.add(cartProduct);
  }
  
  // 3. Create order object
  OrderModel order = {
    id: generateUUID(),
    address: selectedAddress,
    authorID: currentUserId,
    author: currentUser,
    vendorID: vendor.id,
    vendor: vendor,
    adminCommission: vendor.adminCommission || global.adminCommission,
    adminCommissionType: "percentage" or "amount",
    status: "Order_Placed",
    discount: couponAmount,
    couponId: selectedCoupon.id,
    couponCode: selectedCoupon.code,
    taxSetting: taxList,
    paymentMethod: selectedPaymentMethod,
    products: cartItems,
    specialDiscount: {
      special_discount: specialDiscountAmount,
      special_discount_label: specialDiscount,
      specialType: "percentage" or "amount"
    },
    deliveryCharge: deliveryCharges,
    tipAmount: deliveryTips,
    notes: customerNotes,
    takeAway: (selectedFoodType == "Delivery") ? false : true,
    createdAt: Timestamp.now(),
    scheduleTime: (deliveryType == "schedule") ? scheduleDateTime : null
  };
  
  // 4. Handle wallet payment
  if (paymentMethod == "wallet") {
    // Create wallet transaction
    WalletTransaction transaction = {
      id: generateUUID(),
      amount: totalAmount,
      date: Timestamp.now(),
      paymentMethod: "wallet",
      transactionUser: "user",
      userId: currentUserId,
      isTopup: false,
      orderId: order.id,
      note: "Order Amount debited",
      paymentStatus: "success"
    };
    
    // Save transaction
    setWalletTransaction(transaction);
    
    // Deduct from wallet
    updateUserWallet(amount: "-${totalAmount}", userId: currentUserId);
  }
  
  // 5. Update product quantities
  for (each product in cart) {
    productModel = getProductById(product.id);
    
    if (product has variant) {
      // Update variant quantity
      variant = find variant by variantId;
      if (variant.quantity != "-1") {  // -1 means unlimited
        variant.quantity -= product.quantity;
      }
    } else {
      // Update product quantity
      if (product.quantity != -1) {
        product.quantity -= product.quantity;
      }
    }
    
    updateProduct(productModel);
  }
  
  // 6. Save order to Firestore
  setOrder(order);
  
  // 7. Clear cart
  DatabaseHelper.deleteAllCartProducts();
  
  // 8. Send notification to vendor
  vendorUser = getUserProfile(vendor.author);
  if (order.scheduleTime != null) {
    sendFCM("Schedule Order", vendorUser.fcmToken);
  } else {
    sendFCM("New Order Placed", vendorUser.fcmToken);
  }
  
  // 9. Send order email
  sendOrderEmail(order);
  
  // 10. Navigate to order placing screen
  navigateTo(OrderPlacingScreen, {orderModel: order});
}
```

**Key Steps:**
1. Validate payment method
2. Check vendor availability
3. Create order object with all details
4. Process wallet payment (if applicable)
5. Update product stock quantities
6. Save order to Firestore
7. Clear local cart
8. Notify vendor via FCM
9. Send email confirmation
10. Navigate to order confirmation

---

## 📍 ORDER TRACKING LOGIC

### How Real-Time Tracking Works

#### 1. **Live Tracking Controller**
```dart
class LiveTrackingController {
  OrderModel orderModel;
  UserModel driverUserModel;
  GoogleMapController mapController;
  
  onInit() {
    addMarkerSetup();  // Load marker icons
    getArgument();     // Get order from navigation
  }
  
  getArgument() {
    orderModel = Get.arguments['orderModel'];
    
    // Listen to order updates (Firestore real-time)
    Firestore.collection('orders')
      .doc(orderModel.id)
      .snapshots()
      .listen((orderSnapshot) {
        orderModel = OrderModel.fromJson(orderSnapshot.data);
        
        // Listen to driver location (Firestore real-time)
        Firestore.collection('users')
          .doc(orderModel.driverId)
          .snapshots()
          .listen((driverSnapshot) {
            driverUserModel = UserModel.fromJson(driverSnapshot.data);
            
            // Update map based on order status
            if (orderModel.status == "Order_Shipped") {
              // Driver going to restaurant
              getPolyline(
                from: driver.location,
                to: restaurant.location
              );
            } else if (orderModel.status == "In_Transit") {
              // Driver going to customer
              getPolyline(
                from: driver.location,
                to: customer.address
              );
            } else {
              // Show restaurant to customer route
              getPolyline(
                from: restaurant.location,
                to: customer.address
              );
            }
          });
        
        // Close screen if order completed
        if (orderModel.status == "Order_Completed") {
          Get.back();
        }
      });
  }
}
```

**Real-Time Updates:**
1. **Order Status** - Firestore snapshots on `orders/{orderId}`
2. **Driver Location** - Firestore snapshots on `users/{driverId}`
3. **Map Updates** - Recalculate polyline when driver moves
4. **Auto-Close** - Close screen when order completed

#### 2. **Map Marker Logic**
```dart
addMarker(latitude, longitude, id, icon, rotation) {
  Marker marker = Marker(
    markerId: MarkerId(id),
    icon: icon,
    position: LatLng(latitude, longitude),
    rotation: rotation  // Driver rotation for direction
  );
  markers[markerId] = marker;
}

// Three types of markers:
// 1. Departure (Restaurant) - pickup.png
// 2. Destination (Customer) - dropoff.png
// 3. Driver (Moving) - food_delivery.png with rotation
```

#### 3. **Polyline (Route) Logic**
```dart
getPolyline(sourceLatitude, sourceLongitude, destinationLatitude, destinationLongitude) {
  // Use Google Maps Directions API
  PolylineRequest request = {
    origin: PointLatLng(sourceLatitude, sourceLongitude),
    destination: PointLatLng(destinationLatitude, destinationLongitude),
    mode: TravelMode.driving
  };
  
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    request: request,
    googleApiKey: Constant.mapAPIKey
  );
  
  // Convert points to LatLng
  List<LatLng> polylineCoordinates = [];
  for (point in result.points) {
    polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  }
  
  // Add markers based on status
  if (status == "Order_Shipped") {
    addMarker(driver.location, "Driver", driverIcon, driver.rotation);
    addMarker(restaurant.location, "Departure", departureIcon, 0);
  } else if (status == "In_Transit") {
    addMarker(driver.location, "Driver", driverIcon, driver.rotation);
    addMarker(customer.address, "Destination", destinationIcon, 0);
  } else {
    addMarker(restaurant.location, "Departure", departureIcon, 0);
    addMarker(customer.address, "Destination", destinationIcon, 0);
  }
  
  // Draw polyline on map
  _addPolyLine(polylineCoordinates);
}
```

**Map States:**
1. **Order_Placed** - Show restaurant → customer route
2. **Order_Shipped** - Show driver → restaurant route (driver moving)
3. **In_Transit** - Show driver → customer route (driver moving)
4. **Order_Completed** - Close tracking screen

---

## 🔄 ORDER STATUS FLOW

### Status Progression

```
1. Order_Placed
   ↓ (Restaurant accepts)
2. Order_Accepted
   ↓ (Restaurant prepares)
3. Driver_Pending
   ↓ (Driver accepts)
4. Driver_Accepted
   ↓ (Driver picks up)
5. Order_Shipped
   ↓ (Driver on the way)
6. In_Transit
   ↓ (Driver delivers)
7. Order_Completed

// Alternative paths:
Order_Placed → Order_Rejected (Restaurant rejects)
Driver_Pending → Driver_Rejected (Driver rejects)
Any status → Order_Cancelled (Customer cancels)
```

---

## 💰 PAYMENT LOGIC

### Payment Methods Supported

```dart
enum PaymentGateway {
  wallet,
  cod,  // Cash on Delivery
  stripe,
  paypal,
  razorpay,
  payStack,
  flutterWave,
  mercadoPago,
  payFast,
  paytm,
  midTrans,
  orangeMoney,
  xendit
}
```

### Payment Flow

```dart
// 1. Load payment settings from Firestore
getPaymentSettings() {
  stripeModel = getFromPreferences("stripeSettings");
  payPalModel = getFromPreferences("paypalSettings");
  // ... load all payment gateways
  
  // Set default payment method (first enabled)
  if (wallet.isEnabled) {
    selectedPaymentMethod = "wallet";
  } else if (cod.isEnabled) {
    selectedPaymentMethod = "cod";
  } else if (stripe.isEnabled) {
    selectedPaymentMethod = "stripe";
  }
  // ... check all gateways in order
}

// 2. Process payment
placeOrder() {
  if (selectedPaymentMethod == "wallet") {
    // Check balance
    if (walletBalance >= totalAmount) {
      // Deduct from wallet
      // Place order
    }
  } else if (selectedPaymentMethod == "cod") {
    // No payment processing
    // Place order directly
  } else if (selectedPaymentMethod == "stripe") {
    // Show Stripe payment sheet
    stripeMakePayment(amount);
    // After success → placeOrder()
  } else if (selectedPaymentMethod == "razorpay") {
    // Show Razorpay checkout
    razorPayMakePayment(amount);
    // After success → placeOrder()
  }
  // ... handle other gateways
}
```

---

## 🎯 KEY BUSINESS RULES

### 1. **Cart Rules**
- ✅ Only one vendor per cart
- ✅ Must clear cart to add from different vendor
- ✅ Extras price added to item price
- ✅ Discount price takes precedence over regular price
- ✅ Quantity updates replace (not increment)

### 2. **Pricing Rules**
- ✅ Subtotal = Σ(item price + extras) × quantity
- ✅ Coupon applied to subtotal
- ✅ Special discount applied to subtotal
- ✅ Tax applied to (subtotal - discounts)
- ✅ Delivery charge based on distance
- ✅ Tips added at the end
- ✅ Total = subtotal - discounts + tax + delivery + tips

### 3. **Delivery Charge Rules**
- ✅ If distance > minimumKm: charge = distance × perKmRate
- ✅ If distance <= minimumKm: charge = minimumCharge
- ✅ Vendor can override global delivery charge
- ✅ No delivery charge for takeaway orders

### 4. **Special Discount Rules**
- ✅ Time-based (specific days and hours)
- ✅ Only applies during discount window
- ✅ Can be percentage or fixed amount
- ✅ Only for delivery orders (not takeaway)

### 5. **Stock Management**
- ✅ Deduct quantity when order placed
- ✅ Handle variants separately
- ✅ -1 quantity means unlimited stock
- ✅ Update product in Firestore

### 6. **Order Tracking Rules**
- ✅ Real-time updates via Firestore snapshots
- ✅ Driver location updates every few seconds
- ✅ Map shows different routes based on status
- ✅ Auto-close when order completed

---

## 🔄 NODE.JS MIGRATION STRATEGY

### What to Keep (Same Logic)

1. **Cart System** ✅
   - Keep SQLite local storage
   - Keep CartProvider stream pattern
   - Keep same business rules
   - **Change:** Nothing! Cart already local

2. **Price Calculation** ✅
   - Keep exact same formula
   - Keep same calculation order
   - Keep same business rules
   - **Change:** Nothing! Pure calculation logic

3. **Order Placement** ⚠️
   - Keep same validation logic
   - Keep same order structure
   - **Change:** 
     - Firestore → REST API (POST /api/v1/orders)
     - Firebase FCM → Node.js FCM Admin SDK
     - Firestore transactions → MySQL transactions

4. **Order Tracking** ⚠️
   - Keep same UI and map logic
   - **Change:**
     - Firestore snapshots → Socket.IO events
     - Real-time location → Socket.IO streams
     - Status updates → Socket.IO events

5. **Payment Processing** ✅
   - Keep same payment gateway integrations
   - Keep same payment flow
   - **Change:**
     - Save payment to MySQL instead of Firestore
     - Wallet balance in MySQL

---

## 📋 REPLICATION CHECKLIST

### For Each Feature:

1. **Copy UI** ✅
   - Exact same widgets
   - Same layout
   - Same styling

2. **Copy Business Logic** ✅
   - Same calculations
   - Same validations
   - Same rules

3. **Replace Data Layer** ⚠️
   - Firestore → REST API
   - Firebase Realtime → Socket.IO
   - Firebase Storage → Local upload

4. **Keep Local Storage** ✅
   - SQLite for cart
   - SharedPreferences for settings
   - SecureStorage for tokens

---

## 🎯 NEXT STEPS

Now that I understand the logic, I can:

1. **Create exact same models** with Node.js compatibility
2. **Copy controllers** and replace Firestore calls with API calls
3. **Keep cart system** as-is (already local)
4. **Replicate price calculation** exactly
5. **Implement Socket.IO** for real-time tracking
6. **Copy UI screens** with same design

**Ready to start building?** Let me know! 🚀
