[<img src="https://user-images.githubusercontent.com/32601911/230755763-3ed1bb83-a04c-43a6-b9e0-fe8e4dd8a4ed.png" height="206">](https://play.google.com/store/apps/details?id=app.grocerytrip.android)

# GroceryTrip
### Turn receipts into nutritional information. 

GroceryTrip is a Flutter app that helps you view the overall nutrition & ingredients of your groceries more comprehensively. Scan receipts to see overall and detailed product info, and contribute to a growing database!

## :heavy_check_mark: Installation
[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
    alt="Get it on the Play Store"
    height="80">](https://play.google.com/store/apps/details?id=app.grocerytrip.android)

You can also download the .apk file directly clicking the button below. You may need to 'Allow installation from unknown sources' if you've previously only installed apps from the Play Store. 

[<img src="https://github.com/machiav3lli/oandbackupx/blob/034b226cea5c1b30eb4f6a6f313e4dadcbb0ece4/badge_github.png"
    alt="Get it on GitHub"
    height="80">](https://github.com/zanovis/GroceryTrip/releases)

**You can use the app [Obtainium](https://github.com/ImranR98/Obtainium) to keep GroceryTrip up to date.*

## 🌟 Features
- Supports: Trader Joe's receipts, barcode-based receipts (limited)
- Scan receipts for product details
- View compiled nutrition facts
- View ingredients
- Submit unrecognized barcodes
- If product data is missing, you can click a product to contribute to the [OpenFoodFacts](https://github.com/openfoodfacts) database (Directs to the OFF application if you have it installed) 

## 🚀 How it works
1. Take a photo of your grocery store receipt (if you don't have one on-hand, you can use the Demo button!) - _This photo remains local on your device, and does not get uploaded._
3. Crop the image to capture relevant information - _Optical Character Recognition is performed on the cropped image to extract the text, and a database is searched to find each item on the receipt, if the receipt contains a string. Once a match is found (or the receipt contains barcodes), the barcode is searched within the OpenFoodFacts database (nothing is uploaded in this step)._
4. View overall nutrition & ingredients in your groceries
5. Optionally contribute barcodes if any are missing, your grocery list and results will automatically update once a barcode has been submitted for a receipt. - _You can choose to upload barcodes to the Firebase database to improve future results. An account is required to submit barcodes._

⚠️ Note: GroceryTrip is a work in progress and there are many improvements to be made!

## 🤝 Contributing
Non-developers: Any user can contribute barcodes or product data via OpenFoodFacts. 

Developers: This repo includes the entire front-end of GroceryTrip. Build the app as any other Flutter application, let me know if you run into issues. If you'd like to use the same Firebase relational database, please email me with the subject "GroceryTrip Database". 

## 📋 Todo
- Create roadmap
- ~~Deploy to Play Store~~
- ~~Support more stores (open to suggestions) and receipt types~~
- ~~Open-source project~~
- Include Firebase cloud function in git repo to support self-hosted databases
- iOS support

## 📄 License
This project is licensed under the GPLv3 License. See LICENSE for details.

_⚠️ Note: GroceryTrip has no affiliation with any grocery store._
