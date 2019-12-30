import 'package:bloc/bloc.dart';
import 'package:colorstudio/example/contrast/contrast_screen.dart';
import 'package:colorstudio/example/mdc/mdc_home.dart';
import 'package:colorstudio/example/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'example/blocs/blocs.dart';
import 'example/blocs/color_blind/color_blind_bloc.dart';
import 'example/blocs/mdc_selected/mdc_selected_bloc.dart';
import 'example/contrast/shuffle_color.dart';
import 'example/screens/export_colors.dart';
import 'example/screens/home.dart';
import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await openBox();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(BoxedApp());
}

Future openBox() async {
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  return await Hive.openBox<dynamic>("settings");
}

class BoxedApp extends StatefulWidget {
  @override
  _BoxedAppState createState() => _BoxedAppState();
}

class _BoxedAppState extends State<BoxedApp> {
  ColorBlindBloc colorBlindBloc;
  MdcSelectedBloc _mdcSelectedBloc;

  @override
  void initState() {
    super.initState();
    colorBlindBloc = ColorBlindBloc();
    _mdcSelectedBloc = MdcSelectedBloc(getRandomMaterialDark(), colorBlindBloc);
  }

  @override
  void dispose() {
    super.dispose();
    colorBlindBloc.close();
    _mdcSelectedBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.from(
      colorScheme: const ColorScheme.dark(),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<MdcSelectedBloc>(
          create: (context) => _mdcSelectedBloc,
        ),
        BlocProvider<ContrastRatioBloc>(
          create: (context) => ContrastRatioBloc(_mdcSelectedBloc),
        ),
        BlocProvider<ColorBlindBloc>(
          create: (context) => colorBlindBloc,
        )
      ],
      child: MaterialApp(
        routes: {
          "/": (context) {
            return Home();
          },
          "/multiplecontrastcompare": (context) {
            return BlocProvider<MultipleContrastColorBloc>(
              create: (context) => MultipleContrastColorBloc(
                BlocProvider.of<MdcSelectedBloc>(context),
              ),
              child: const MultipleContrastScreen(),
            );
          },
          "/colordetails": (context) {
            updateStateIfNecessary();
            return SingleColorHome();
          },
          "/componentspreview": (context) {
            // necessary if it opens in split-view
            updateStateIfNecessary();
            return MDCHome();
          },
          "/export" : (context) => ExportColors(),
        },
        theme: base.copyWith(
          typography: Typography().copyWith(
            black: Typography.dense2018,
            tall: Typography.tall2018,
            englishLike: Typography.englishLike2018,
          ),
          dialogTheme: base.dialogTheme.copyWith(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
          ),
          buttonTheme: base.buttonTheme.copyWith(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultRadius / 2),
            ),
          ),
          cardTheme: base.cardTheme.copyWith(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
          ),
        ),
      ),
    );
  }

  void updateStateIfNecessary() {
    final currentState = (_mdcSelectedBloc.state as MDCLoadedState);

    if (currentState.locked[currentState.selected] == true) {
      _mdcSelectedBloc.add(
        MDCLoadEvent(
          currentColor: currentState.rgbColors[kPrimary],
          selected: kPrimary,
        ),
      );
    }
  }
}
