//MambaCoin class used to have a widget of mamba coin
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/app/style/Styles.dart';

class MambaCoin {
  //Mmaba coin with value and or animation
  Widget mambaCoin(var context, String? sessions, double? size, var image,
      animation, bool animate) {
    image =
        'https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mamba_logo.png?alt=media&token=a4307bd0-0c20-497f-abe7-0ada93129b85';
    print(size.toString());

    if (animate) {
      return RotationTransition(
        turns: animation,
        //duration: const Duration(seconds: 5),
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Styles.mainColorTrans,
            borderRadius: BorderRadius.circular(100),
            image: DecorationImage(
              image: NetworkImage(image),
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), BlendMode.dstATop),
            ),
            //more than 50% of width makes circle
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sessions!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: false ? FontWeight.normal : FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.02),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: Styles.mainColorTrans,
          borderRadius: BorderRadius.circular(100),
          image: DecorationImage(
            image: NetworkImage(image),
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3), BlendMode.dstATop),
          ),
          //more than 50% of width makes circle
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sessions!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: false ? FontWeight.normal : FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.02),
              ),
            ],
          ),
        ),
      );
    }
    /*
    Container(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sessions!,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontWeight:
                      false ? FontWeight.normal : FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height*0.03
                  ),
                ),
              ],
            ),
          ),
        ),
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.001,
            horizontal: MediaQuery.of(context).size.width * 0.001),
        shape: CircleBorder(
          side: BorderSide(
              width: MediaQuery.of(context).size.width * 0.005,
              color:  Styles.mainColor),
        );


     */
  }

  //Mmaba coin with value and or animation
  Widget mambaCoinStatic(
      var context, String? sessions, double? size, var image) {
    image =
        'https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mamba_logo.png?alt=media&token=a4307bd0-0c20-497f-abe7-0ada93129b85';
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: Styles.mainColorTrans,
        borderRadius: BorderRadius.circular(100),
        image: DecorationImage(
          image: NetworkImage(image),
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), BlendMode.dstATop),
        ),
        //more than 50% of width makes circle
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sessions!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: false ? FontWeight.normal : FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.02),
            ),
          ],
        ),
      ),
    );
    /*
    Container(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sessions!,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontWeight:
                      false ? FontWeight.normal : FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height*0.03
                  ),
                ),
              ],
            ),
          ),
        ),
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.001,
            horizontal: MediaQuery.of(context).size.width * 0.001),
        shape: CircleBorder(
          side: BorderSide(
              width: MediaQuery.of(context).size.width * 0.005,
              color:  Styles.mainColor),
        );


     */
  }

  //Mamba coin logo
  Widget mambaCoinLogo(var context) {
    var image =
        'https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mamba_logo.png?alt=media&token=a4307bd0-0c20-497f-abe7-0ada93129b85';
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: Styles.mainColorTrans,
        borderRadius: BorderRadius.circular(100),
        image: DecorationImage(
          image: NetworkImage(image),
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3), BlendMode.dstATop),
        ),
        //more than 50% of width makes circle
      ),
    );
    /*
    Container(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sessions!,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontWeight:
                      false ? FontWeight.normal : FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height*0.03
                  ),
                ),
              ],
            ),
          ),
        ),
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.001,
            horizontal: MediaQuery.of(context).size.width * 0.001),
        shape: CircleBorder(
          side: BorderSide(
              width: MediaQuery.of(context).size.width * 0.005,
              color:  Styles.mainColor),
        );


     */
  }
}
