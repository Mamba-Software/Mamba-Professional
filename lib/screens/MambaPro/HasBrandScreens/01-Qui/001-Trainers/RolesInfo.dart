import 'package:flutter/material.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/app/style/AppColors.dart';

class RolesInfo extends StatelessWidget {
  const RolesInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              height: MediaQuery.of(context).size.height * 0.007,
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.84,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Text(context.l10n.roles,
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.left),
                  ),
                  Flexible(
                    child: Text(context.l10n.rolesInfoDescription,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(height: 1.5),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          width: 1.0,
                          color: Theme.of(context).colorScheme.background),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      topLeft: Radius.circular(5.0),
                    ), //
                  ),
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          context.l10n.trainer,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          context.l10n.administrador,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          context.l10n.owner,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    children: [
                      // Events
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.events,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.addEvent,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.editEvent,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Bonos
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.rates,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.add} ${context.l10n.bono.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.edit} ${context.l10n.bono.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.confirm} ${context.l10n.rates.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.acceptBono,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Miembros
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.members,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.chatBottomNav,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.add} ${context.l10n.client.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.add} ${context.l10n.trainer.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.confirm} ${context.l10n.request.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.delete} ${context.l10n.member.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Estadisticas
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.stats,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.events,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.clients,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      /*
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(width: 1.0, color: Theme.of(context).backgroundColor),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.staff,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(width: 1.0, color: Theme.of(context).backgroundColor),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(Icons.check, color: Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.03,),
                                  const SizedBox(width: 20),
                                  Icon(Icons.check, color: AppColors.mainColor, size: MediaQuery.of(context).size.width*0.03,),
                                  const SizedBox(width: 20),
                                  Icon(Icons.check, color: AppColors.mainColor, size: MediaQuery.of(context).size.width*0.03,),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                       Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(width: 1.0, color: Theme.of(context).backgroundColor),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.bonos,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(width: 1.0, color: Theme.of(context).backgroundColor),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(Icons.check, color: Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.03,),
                                  const SizedBox(width: 20),
                                  Icon(Icons.check, color: AppColors.mainColor, size: MediaQuery.of(context).size.width*0.03,),
                                  const SizedBox(width: 20),
                                  Icon(Icons.check, color: AppColors.mainColor, size: MediaQuery.of(context).size.width*0.03,),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                       */
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.facturation,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Marca
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  context.l10n.brand,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.edit} ${context.l10n.information.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.edit} ${context.l10n.roles.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.add} ${context.l10n.photos.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.add} ${context.l10n.locations.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "${context.l10n.edit} ${context.l10n.locations.toLowerCase()}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.paySubscription,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      textAlign: TextAlign.left,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.l10n.paySubscriptionDesc,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 13),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 0),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 20),
                                  Icon(
                                    Icons.check,
                                    color: AppColors.mainColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Footer
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(5.0),
                                bottomRight: Radius.circular(5.0),
                              ), //
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
