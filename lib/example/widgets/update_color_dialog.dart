// user defined function
import 'package:colorstudio/example/blocs/mdc_selected/mdc_selected_bloc.dart';
import 'package:colorstudio/example/blocs/mdc_selected/mdc_selected_event.dart';
import 'package:colorstudio/example/util/color_util.dart';
import 'package:colorstudio/example/util/constants.dart';
import 'package:colorstudio/example/widgets/color_sliders.dart';
import 'package:colorstudio/example/widgets/loading_indicator.dart';
import 'package:colorstudio/example/widgets/selectable_sliders.dart';
import 'package:colorstudio/example/widgets/text_form_colored.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../blocs/slider_color/slider_color.dart';

Future<void> showSlidersDialog(
  BuildContext context,
  Color color, [
  String selected,
]) async {
  final dynamic result = await showDialog<dynamic>(
      context: context,
      builder: (BuildContext ctx) {
        return BlocProvider(
          create: (context) => SliderColorBloc()..add(MoveColor(color, true)),
          child: UpdateColorDialog(color),
        );
      });

  if (result != null) {
    if (selected == null && result is Color) {
      BlocProvider.of<MdcSelectedBloc>(context).add(
        MDCLoadEvent(currentColor: result),
      );
//      BlocProvider.of<SliderColorBloc>(context).add(MoveColor(result, true));
    } else if (result is Color && selected != null) {
      BlocProvider.of<MdcSelectedBloc>(context).add(
        MDCUpdateColor(
          color: result,
          selected: selected,
        ),
      );
    }
  }
}

class UpdateColorDialog extends StatelessWidget {
  const UpdateColorDialog(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return BlocBuilder<SliderColorBloc, SliderColorState>(
      builder: (context, state) {
        if (state is SliderColorLoading) {
          return const Scaffold(body: LoadingIndicator());
        }

        final Color color = (state as SliderColorLoaded).rgbColor;

        if ((state as SliderColorLoaded).updateTextField) {
          final clrStr = color.toStr();

          if (controller.text != clrStr) {
            setTextAndPosition(controller, clrStr);
          }
        }

        final rgb = RGBSlider(
            color: color,
            onChanged: (r, g, b) {
              BlocProvider.of<SliderColorBloc>(context).add(MoveRGB(r, g, b));
            });

        final hsluv = HSLuvSlider(
            color: (state as SliderColorLoaded).hsluvColor,
            onChanged: (h, s, l) {
              BlocProvider.of<SliderColorBloc>(context).add(MoveHSLuv(h, s, l));
            });

        final hsv = HSVSlider(
            color: (state as SliderColorLoaded).hsvColor,
            onChanged: (h, s, v) {
              BlocProvider.of<SliderColorBloc>(context).add(MoveHSV(h, s, v));
            });

        final surface = color.computeLuminance() > kLumContrast
            ? Colors.black.withOpacity(0.20)
            : Colors.white.withOpacity(0.20);

        final scheme = color.computeLuminance() > kLumContrast
            ? ColorScheme.light(primary: color, surface: surface)
            : ColorScheme.dark(primary: color, surface: surface);

        final selectableColor = compositeColors(
          scheme.background,
          scheme.primary,
          0.20,
        );

        const radius = 16.0;

        return Theme(
          data: ThemeData.from(colorScheme: scheme).copyWith(
            highlightColor: surface,
            textSelectionColor: surface,
            textSelectionHandleColor: surface,
          ),
          child: AlertDialog(
            contentPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius)),
            backgroundColor: color,
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormColored(controller: controller, radius: radius),
                Card(
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(radius),
                      bottomLeft: Radius.circular(radius),
                    ),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 12.0, bottom: 8.0),
                    child: SliderWithSelector(
                      [rgb, hsluv, hsv],
                      color,
                      selectableColor,
                      context,
                    ),
                  ),
                ),
//                const SizedBox(height: 8),
//                SizedBox(
//                  width: 500,
//                  height: 36,
//                  child: Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: FlatButton.icon(
//                          color: selectableColor,
//                          onPressed: () {
//                            copyToClipboard(context, controller.text);
//                          },
//                          shape: RoundedRectangleBorder(
//                            side: BorderSide(color: surface),
//                            borderRadius: BorderRadius.circular(24.0),
//                          ),
//                          icon: Icon(FeatherIcons.copy, size: 16),
//                          label: const Text("Copy"),
//                        ),
//                      ),
//                      SizedBox(width: 8),
//                      Expanded(
//                        child: FlatButton.icon(
//                          color: selectableColor,
//                          onPressed: () => getClipBoardData(),
//                          shape: RoundedRectangleBorder(
//                            side: BorderSide(color: surface),
//                            borderRadius: BorderRadius.circular(24.0),
//                          ),
//                          icon: Icon(FeatherIcons.clipboard, size: 16),
//                          label: const Text("Paste"),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 500,
                  height: 36,
                  child: FlatButton.icon(
                    color: selectableColor,
                    onPressed: () {
                      Navigator.of(context).pop(color);
                    },
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: surface),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    icon: Icon(FeatherIcons.check, size: 16),
                    label: const Text("Select"),
                  ),
                ),
//                   const SizedBox(height: 16),
//                  NearestColor(color: color),
              ],
            ),
          ),
        );
      },
    );
  }

  // this is necessary because of https://github.com/flutter/flutter/issues/11416
  void setTextAndPosition(TextEditingController controller, String newText,
      {int caretPosition}) {
    final int offset = caretPosition ?? newText.length;
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}
