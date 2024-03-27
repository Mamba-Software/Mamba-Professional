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
int display1 = 30; // For large, expressive text
int display2 = 28; // Lesser emphasis compared to display1
int headline1 = 24; // Primary title, more prominent
int headline2 = 20; // Secondary title, slightly less prominent than headline1
int headline3 = 18; // Tertiary title, useful for widget titles or modal headers
int subtitle1 = 16; // For subtitles under headlines or titles
int subtitle2 = 14; // Smaller subtitles, for less emphasis
int bodyText1 = 16; // Main body text, improved for readability
int bodyText2 = 14; // Secondary body text
int caption = 12; // For captions under images or to denote additional information
int overline = 10; // For overlines, often used in material design for categories or to introduce content


// App
var androidGooglePlayUrl =
    "https://play.google.com/store/apps/details?id=com.mamba.mambaprofessionalapp";
var iosAppStoreUrl =
    "https://apps.apple.com/es/app/mamba-professional/id1642701679";

// Contact
var contactEmail = "contacto@mambafitness.es";
var contactNumber = "+34677909194";
var contactNumberMessage =
    "¡Hola! Estoy interesad@ en saber más sobre sus servicios. ¿Podrían proporcionarme más información?";
var whatsappUrl =
    "whatsapp://send?phone=$contactNumber&text=${Uri.encodeComponent(contactNumberMessage)}";

// Website
var website = "https://mambafitness.es/";
var termsAndConditions = "https://mambafitness.es/terminos-y-condiciones/";
var privacy = "https://mambafitness.es/privacidad/";
var functionalities = "https://mambafitness.es/profesionales/";

// Stripe
var stripeConnect = "https://stripe.com/es/privacy";
var stripeTermsAndConditions = "https://stripe.com/es/connect";
