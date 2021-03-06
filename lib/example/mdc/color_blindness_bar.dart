import 'dart:math' as math;

import 'package:colorstudio/example/blocs/blocs.dart';
import 'package:colorstudio/example/mdc/util/color_blind_from_index.dart';
import 'package:colorstudio/example/screens/single_color_blindness.dart';
import 'package:colorstudio/example/util/constants.dart';
import 'package:colorstudio/example/vertical_picker/app_bar_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorBlindnessBar extends StatelessWidget {
  const ColorBlindnessBar({this.onPressed});

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MdcSelectedBloc, MdcSelectedState>(
        builder: (BuildContext context, state) {
      final currentState = state as MDCLoadedState;

      final blindnessSelected = currentState.blindnessSelected;

      final ColorWithBlind blindPrimary = getColorBlindFromIndex(
        currentState.rgbColors[kPrimary],
        blindnessSelected,
      );

      return Center(
        child: Container(
          height: 56,
          width: 500,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 8),
              BorderedIconButton(
                child: Transform.rotate(
                  angle: 0.5 * math.pi,
                  child: const Icon(FeatherIcons.sliders, size: 16),
                ),
                onPressed: onPressed,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      blindPrimary?.name ?? "Color Blindness",
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      blindPrimary?.affects ?? "None selected",
                      style: GoogleFonts.openSans(
                        textStyle: Theme.of(context).textTheme.caption,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Text(
                "$blindnessSelected/8",
                style: GoogleFonts.b612Mono(),
              ),
              const SizedBox(width: 8),
              Material(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.20),
                    ),
                  ),
                  color: currentState.rgbColorsWithBlindness[kBackground],
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: FlatButton(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(),
                          child: Icon(FeatherIcons.chevronLeft),
                          onPressed: () {
                            int newState = blindnessSelected - 1;
                            if (newState < 0) {
                              newState = 8;
                            }
                            BlocProvider.of<ColorBlindBloc>(context)
                                .add(newState);
                          },
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.20),
                      ),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: FlatButton(
                          padding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(),
                          child: Icon(FeatherIcons.chevronRight),
                          onPressed: () {
                            int newState = blindnessSelected + 1;
                            if (newState > 8) {
                              newState = 0;
                            }
                            BlocProvider.of<ColorBlindBloc>(context)
                                .add(newState);
                          },
                        ),
                      ),
                    ],
                  )),
              const SizedBox(width: 8),
            ],
          ),
        ),
      );
    });
  }
}
