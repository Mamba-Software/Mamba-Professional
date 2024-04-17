import 'package:mamba/data/Models/Brand.dart';

//BonosUtils Class is used to administrate all the bonos
class MultipleBrandsUtils {
  static bool checkIfUserHasThisBrand(
      String brandId, List<Brand> userBrandList) {
    Brand brand;
    try {
      brand = userBrandList.firstWhere((brand) => brand.id == brandId);
      if (brand != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
