// Name
String appName = "Mamba";

// Flavor
enum Flavor {
  production,
  staging,
  development,
}

Flavor flavor = Flavor.development;

// Standard Language
String standardLanguage = "es";

// Text Fonts
String mainFontFamily = "UberMove";
String displayFontFamily = "UberMove";

// Text Sizes
double display1 = 30; // For large, expressive text
double headline1 = 25; // Primary title, more prominent
double headline2 =
    20; // Secondary title, slightly less prominent than headline1
double headline3 =
    18; // Tertiary title, useful for widget titles or modal headers
double title1 = 16; // For subtitles under headlines or titles
double body1 = 14; // Main body text, improved for readability
double body2 = 12; // Secondary body text
double body3 = 10; // Tertiary body text

// Icon Sizes
double iconSizeBig = 30;
double iconSize = 25;
double iconSizeSmall = 15;

// Border Radius
double borderRadiusSmall = 5;
double borderRadiusMedium = 10;
double borderRadiusBig = 20;

// Snackbar
int snackbarDefaultDuration = 5;

// App
var androidGooglePlayUrl =
    "https://play.google.com/store/apps/details?id=com.mamba.mambaprofessionalapp";
var iosAppStoreUrl =
    "https://apps.apple.com/es/app/mamba-professional/id1642701679";

// Contact
var contactEmail = "contacto@mambafitness.es";
var contactNumber = "+34677909194";
var contactNumberMessage =
    "¡Hola! Estoy doubleeresad@ en saber más sobre sus servicios. ¿Podrían proporcionarme más información?";
var whatsappUrl =
    "whatsapp://send?phone=$contactNumber&text=${Uri.encodeComponent(contactNumberMessage)}";

// Website
var website = "https://mambafitness.es/";
var termsAndConditions = "https://mambafitness.es/terminos-y-condiciones/";
var privacy = "https://mambafitness.es/privacidad/";
var functionalities = "https://mambafitness.es/profesionales/";
var profesionals = "https://mambafitness.es/profesionales/";
var clients = "https://mambafitness.es/clientes/";
var pricing = "https://mambafitness.es/demo/";

// Stripe
var stripeConnect = "https://stripe.com/es/privacy";
var stripeTermsAndConditions = "https://stripe.com/es/connect";
