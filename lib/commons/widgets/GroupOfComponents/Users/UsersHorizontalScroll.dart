import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';

class UsersHorizontalScroll extends StatefulWidget {
  final List<Usuario> usuarios;
  final double height;
  final double width;

  const UsersHorizontalScroll(
      {super.key,
      required this.height,
      required this.width,
      required this.usuarios});

  @override
  _UsersHorizontalScrollState createState() => _UsersHorizontalScrollState();
}

class _UsersHorizontalScrollState extends State<UsersHorizontalScroll> {
  // Navigate to Settings Brand Screen
  void navigateToUserProfileScreen(String userId) {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
            builder: (context) =>
                ProfileViewUser(userID: userId, viewOnly: false)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: widget.usuarios.length,
          itemBuilder: (context, int index) {
            var user = widget.usuarios[index];
            return GestureDetector(
              onTap: () => navigateToUserProfileScreen(user.id!),
              child: Padding(
                padding: !(index == 0 || index == widget.usuarios.length - 1)
                    ? const EdgeInsets.symmetric(horizontal: 8.0)
                    : (index == 0)
                        ? EdgeInsets.only(left: widget.width * 0.06, right: 8.0)
                        : EdgeInsets.only(
                            right: widget.usuarios.length != 1
                                ? widget.width * 0.06
                                : 8.0,
                            left: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircularImage(
                      size: widget.width * 0.18,
                      image: user.imageUrl,
                      color: Theme.of(context).primaryColor,
                      borderWidth: 1,
                    ),
                    SizedBox(
                      width: widget.width * 0.2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              user.firstName!,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
