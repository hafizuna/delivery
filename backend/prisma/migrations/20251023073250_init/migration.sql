-- CreateTable
CREATE TABLE `users` (
    `id` VARCHAR(191) NOT NULL,
    `phoneNumber` VARCHAR(191) NOT NULL,
    `countryCode` VARCHAR(191) NOT NULL DEFAULT '+1',
    `passwordHash` VARCHAR(191) NOT NULL,
    `firstName` VARCHAR(191) NOT NULL,
    `lastName` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NULL,
    `profilePictureURL` TEXT NULL,
    `fcmToken` TEXT NULL,
    `walletAmount` DECIMAL(10, 2) NOT NULL DEFAULT 0,
    `active` BOOLEAN NOT NULL DEFAULT true,
    `isActive` BOOLEAN NOT NULL DEFAULT true,
    `isDocumentVerify` BOOLEAN NOT NULL DEFAULT false,
    `role` ENUM('customer', 'driver', 'restaurant', 'admin') NOT NULL,
    `provider` VARCHAR(191) NULL,
    `appIdentifier` VARCHAR(191) NULL,
    `zoneId` VARCHAR(191) NULL,
    `carName` VARCHAR(191) NULL,
    `carNumber` VARCHAR(191) NULL,
    `carPictureURL` TEXT NULL,
    `latitude` DOUBLE NULL,
    `longitude` DOUBLE NULL,
    `rotation` DOUBLE NULL DEFAULT 0,
    `vendorId` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `users_phoneNumber_key`(`phoneNumber`),
    UNIQUE INDEX `users_vendorId_key`(`vendorId`),
    INDEX `users_phoneNumber_idx`(`phoneNumber`),
    INDEX `users_role_idx`(`role`),
    INDEX `users_zoneId_idx`(`zoneId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `shipping_addresses` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `address` TEXT NOT NULL,
    `addressAs` VARCHAR(191) NOT NULL,
    `landmark` TEXT NULL,
    `locality` TEXT NOT NULL,
    `latitude` DOUBLE NOT NULL,
    `longitude` DOUBLE NOT NULL,
    `isDefault` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `shipping_addresses_userId_idx`(`userId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `vendors` (
    `id` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `description` TEXT NULL,
    `photo` TEXT NULL,
    `latitude` DOUBLE NOT NULL,
    `longitude` DOUBLE NOT NULL,
    `location` TEXT NOT NULL,
    `phoneNumber` VARCHAR(191) NOT NULL,
    `categoryId` VARCHAR(191) NOT NULL,
    `restaurantCost` DECIMAL(10, 2) NOT NULL,
    `hidephotos` BOOLEAN NOT NULL DEFAULT false,
    `reststatus` BOOLEAN NOT NULL DEFAULT true,
    `reviewsCount` INTEGER NOT NULL DEFAULT 0,
    `reviewsSum` DOUBLE NOT NULL DEFAULT 0,
    `zoneId` VARCHAR(191) NOT NULL,
    `fcmToken` TEXT NULL,
    `walletAmount` DECIMAL(10, 2) NOT NULL DEFAULT 0,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `vendors_categoryId_idx`(`categoryId`),
    INDEX `vendors_zoneId_idx`(`zoneId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `vendor_categories` (
    `id` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `photo` TEXT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `vendor_photos` (
    `id` VARCHAR(191) NOT NULL,
    `vendorId` VARCHAR(191) NOT NULL,
    `url` TEXT NOT NULL,

    INDEX `vendor_photos_vendorId_idx`(`vendorId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `vendor_menu_photos` (
    `id` VARCHAR(191) NOT NULL,
    `vendorId` VARCHAR(191) NOT NULL,
    `url` TEXT NOT NULL,

    INDEX `vendor_menu_photos_vendorId_idx`(`vendorId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `vendor_working_hours` (
    `id` VARCHAR(191) NOT NULL,
    `vendorId` VARCHAR(191) NOT NULL,
    `day` VARCHAR(191) NOT NULL,
    `fromTime` VARCHAR(191) NULL,
    `toTime` VARCHAR(191) NULL,

    INDEX `vendor_working_hours_vendorId_idx`(`vendorId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `vendor_special_discounts` (
    `id` VARCHAR(191) NOT NULL,
    `vendorId` VARCHAR(191) NOT NULL,
    `day` VARCHAR(191) NOT NULL,
    `discount` VARCHAR(191) NOT NULL,
    `fromTime` VARCHAR(191) NOT NULL,
    `toTime` VARCHAR(191) NOT NULL,
    `type` VARCHAR(191) NOT NULL,

    INDEX `vendor_special_discounts_vendorId_idx`(`vendorId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `products` (
    `id` VARCHAR(191) NOT NULL,
    `vendorId` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `description` TEXT NULL,
    `photo` TEXT NULL,
    `price` DECIMAL(10, 2) NOT NULL,
    `discountPrice` DECIMAL(10, 2) NULL,
    `categoryId` VARCHAR(191) NULL,
    `isAvailable` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `products_vendorId_idx`(`vendorId`),
    INDEX `products_categoryId_idx`(`categoryId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `product_photos` (
    `id` VARCHAR(191) NOT NULL,
    `productId` VARCHAR(191) NOT NULL,
    `url` TEXT NOT NULL,

    INDEX `product_photos_productId_idx`(`productId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `orders` (
    `id` VARCHAR(191) NOT NULL,
    `customerId` VARCHAR(191) NOT NULL,
    `vendorId` VARCHAR(191) NOT NULL,
    `driverId` VARCHAR(191) NULL,
    `status` ENUM('Order_Placed', 'Order_Accepted', 'Order_Rejected', 'Driver_Pending', 'Driver_Accepted', 'Driver_Rejected', 'Order_Shipped', 'In_Transit', 'Order_Completed', 'Order_Cancelled') NOT NULL DEFAULT 'Order_Placed',
    `addressId` VARCHAR(191) NULL,
    `deliveryAddress` TEXT NULL,
    `deliveryLatitude` DOUBLE NULL,
    `deliveryLongitude` DOUBLE NULL,
    `deliveryLocality` TEXT NULL,
    `deliveryLandmark` TEXT NULL,
    `subtotal` DECIMAL(10, 2) NOT NULL,
    `discount` DECIMAL(10, 2) NOT NULL DEFAULT 0,
    `deliveryCharge` DECIMAL(10, 2) NOT NULL DEFAULT 0,
    `tipAmount` DECIMAL(10, 2) NOT NULL DEFAULT 0,
    `totalAmount` DECIMAL(10, 2) NOT NULL,
    `platformCommission` DECIMAL(10, 2) NOT NULL,
    `deliveryCommission` DECIMAL(10, 2) NOT NULL,
    `couponId` VARCHAR(191) NULL,
    `couponCode` VARCHAR(191) NULL,
    `specialDiscount` JSON NULL,
    `paymentMethod` VARCHAR(191) NOT NULL,
    `paymentStatus` VARCHAR(191) NOT NULL DEFAULT 'pending',
    `takeAway` BOOLEAN NOT NULL DEFAULT false,
    `estimatedTimeToPrepare` VARCHAR(191) NULL,
    `scheduleTime` DATETIME(3) NULL,
    `triggerDelivery` DATETIME(3) NULL,
    `notes` TEXT NULL,
    `rejectedByDrivers` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `completedAt` DATETIME(3) NULL,

    INDEX `orders_customerId_idx`(`customerId`),
    INDEX `orders_vendorId_idx`(`vendorId`),
    INDEX `orders_driverId_idx`(`driverId`),
    INDEX `orders_status_idx`(`status`),
    INDEX `orders_createdAt_idx`(`createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `order_items` (
    `id` VARCHAR(191) NOT NULL,
    `orderId` VARCHAR(191) NOT NULL,
    `productId` VARCHAR(191) NOT NULL,
    `productName` VARCHAR(191) NOT NULL,
    `quantity` INTEGER NOT NULL,
    `price` DECIMAL(10, 2) NOT NULL,
    `discountPrice` DECIMAL(10, 2) NULL,

    INDEX `order_items_orderId_idx`(`orderId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `order_status_history` (
    `id` VARCHAR(191) NOT NULL,
    `orderId` VARCHAR(191) NOT NULL,
    `status` ENUM('Order_Placed', 'Order_Accepted', 'Order_Rejected', 'Driver_Pending', 'Driver_Accepted', 'Driver_Rejected', 'Order_Shipped', 'In_Transit', 'Order_Completed', 'Order_Cancelled') NOT NULL,
    `changedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `changedBy` VARCHAR(191) NULL,
    `note` TEXT NULL,

    INDEX `order_status_history_orderId_idx`(`orderId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `chat_messages` (
    `id` VARCHAR(191) NOT NULL,
    `orderId` VARCHAR(191) NOT NULL,
    `senderId` VARCHAR(191) NOT NULL,
    `receiverId` VARCHAR(191) NOT NULL,
    `message` TEXT NOT NULL,
    `messageType` VARCHAR(191) NOT NULL DEFAULT 'text',
    `mediaUrl` TEXT NULL,
    `mediaMimeType` VARCHAR(191) NULL,
    `videoThumbnail` TEXT NULL,
    `isRead` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `chat_messages_orderId_idx`(`orderId`),
    INDEX `chat_messages_senderId_idx`(`senderId`),
    INDEX `chat_messages_receiverId_idx`(`receiverId`),
    INDEX `chat_messages_createdAt_idx`(`createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `zones` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `area` JSON NOT NULL,
    `publish` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `coupons` (
    `id` VARCHAR(191) NOT NULL,
    `code` VARCHAR(191) NOT NULL,
    `description` TEXT NULL,
    `discount` DECIMAL(10, 2) NOT NULL,
    `discountType` VARCHAR(191) NOT NULL,
    `minOrder` DECIMAL(10, 2) NULL,
    `maxDiscount` DECIMAL(10, 2) NULL,
    `validFrom` DATETIME(3) NOT NULL,
    `validTo` DATETIME(3) NOT NULL,
    `isActive` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `coupons_code_key`(`code`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `wallet_transactions` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `type` VARCHAR(191) NOT NULL,
    `transactionType` VARCHAR(191) NOT NULL,
    `orderId` VARCHAR(191) NULL,
    `note` TEXT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `wallet_transactions_userId_idx`(`userId`),
    INDEX `wallet_transactions_createdAt_idx`(`createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `favorite_restaurants` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `vendorId` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `favorite_restaurants_userId_idx`(`userId`),
    UNIQUE INDEX `favorite_restaurants_userId_vendorId_key`(`userId`, `vendorId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `favorite_items` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `productId` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `favorite_items_userId_idx`(`userId`),
    UNIQUE INDEX `favorite_items_userId_productId_key`(`userId`, `productId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `reviews` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `vendorId` VARCHAR(191) NULL,
    `productId` VARCHAR(191) NULL,
    `rating` DOUBLE NOT NULL,
    `comment` TEXT NULL,
    `photos` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `reviews_userId_idx`(`userId`),
    INDEX `reviews_vendorId_idx`(`vendorId`),
    INDEX `reviews_productId_idx`(`productId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `gift_cards` (
    `id` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `description` TEXT NULL,
    `imageUrl` TEXT NULL,
    `isActive` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `gift_card_purchases` (
    `id` VARCHAR(191) NOT NULL,
    `giftCardId` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `code` VARCHAR(191) NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `isRedeemed` BOOLEAN NOT NULL DEFAULT false,
    `redeemedBy` VARCHAR(191) NULL,
    `redeemedAt` DATETIME(3) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `gift_card_purchases_code_key`(`code`),
    INDEX `gift_card_purchases_userId_idx`(`userId`),
    INDEX `gift_card_purchases_code_idx`(`code`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `referrals` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `referralCode` VARCHAR(191) NOT NULL,
    `referredBy` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `referrals_referralCode_key`(`referralCode`),
    INDEX `referrals_userId_idx`(`userId`),
    INDEX `referrals_referralCode_idx`(`referralCode`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `driver_payouts` (
    `id` VARCHAR(191) NOT NULL,
    `driverId` VARCHAR(191) NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `payoutMethod` VARCHAR(191) NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'pending',
    `note` TEXT NULL,
    `processedAt` DATETIME(3) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `driver_payouts_driverId_idx`(`driverId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `notifications` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NULL,
    `title` VARCHAR(191) NOT NULL,
    `body` TEXT NOT NULL,
    `type` VARCHAR(191) NOT NULL,
    `data` JSON NULL,
    `isRead` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `notifications_userId_idx`(`userId`),
    INDEX `notifications_createdAt_idx`(`createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `app_settings` (
    `id` VARCHAR(191) NOT NULL,
    `key` VARCHAR(191) NOT NULL,
    `value` JSON NOT NULL,

    UNIQUE INDEX `app_settings_key_key`(`key`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `users` ADD CONSTRAINT `users_vendorId_fkey` FOREIGN KEY (`vendorId`) REFERENCES `vendors`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `users` ADD CONSTRAINT `users_zoneId_fkey` FOREIGN KEY (`zoneId`) REFERENCES `zones`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `shipping_addresses` ADD CONSTRAINT `shipping_addresses_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `vendors` ADD CONSTRAINT `vendors_categoryId_fkey` FOREIGN KEY (`categoryId`) REFERENCES `vendor_categories`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `vendors` ADD CONSTRAINT `vendors_zoneId_fkey` FOREIGN KEY (`zoneId`) REFERENCES `zones`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `vendor_photos` ADD CONSTRAINT `vendor_photos_vendorId_fkey` FOREIGN KEY (`vendorId`) REFERENCES `vendors`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `vendor_menu_photos` ADD CONSTRAINT `vendor_menu_photos_vendorId_fkey` FOREIGN KEY (`vendorId`) REFERENCES `vendors`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `vendor_working_hours` ADD CONSTRAINT `vendor_working_hours_vendorId_fkey` FOREIGN KEY (`vendorId`) REFERENCES `vendors`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `vendor_special_discounts` ADD CONSTRAINT `vendor_special_discounts_vendorId_fkey` FOREIGN KEY (`vendorId`) REFERENCES `vendors`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `products` ADD CONSTRAINT `products_vendorId_fkey` FOREIGN KEY (`vendorId`) REFERENCES `vendors`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `product_photos` ADD CONSTRAINT `product_photos_productId_fkey` FOREIGN KEY (`productId`) REFERENCES `products`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `orders` ADD CONSTRAINT `orders_customerId_fkey` FOREIGN KEY (`customerId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `orders` ADD CONSTRAINT `orders_vendorId_fkey` FOREIGN KEY (`vendorId`) REFERENCES `vendors`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `orders` ADD CONSTRAINT `orders_driverId_fkey` FOREIGN KEY (`driverId`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `order_items` ADD CONSTRAINT `order_items_orderId_fkey` FOREIGN KEY (`orderId`) REFERENCES `orders`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `order_status_history` ADD CONSTRAINT `order_status_history_orderId_fkey` FOREIGN KEY (`orderId`) REFERENCES `orders`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `chat_messages` ADD CONSTRAINT `chat_messages_senderId_fkey` FOREIGN KEY (`senderId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `wallet_transactions` ADD CONSTRAINT `wallet_transactions_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `favorite_restaurants` ADD CONSTRAINT `favorite_restaurants_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `favorite_items` ADD CONSTRAINT `favorite_items_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `reviews` ADD CONSTRAINT `reviews_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `gift_card_purchases` ADD CONSTRAINT `gift_card_purchases_giftCardId_fkey` FOREIGN KEY (`giftCardId`) REFERENCES `gift_cards`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `gift_card_purchases` ADD CONSTRAINT `gift_card_purchases_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `referrals` ADD CONSTRAINT `referrals_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `driver_payouts` ADD CONSTRAINT `driver_payouts_driverId_fkey` FOREIGN KEY (`driverId`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
