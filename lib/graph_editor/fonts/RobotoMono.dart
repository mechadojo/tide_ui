import 'vector_font.dart';

import 'RobotoMono-Bold.dart';
import 'RobotoMono-BoldItalic.dart';
import 'RobotoMono-Light.dart';
import 'RobotoMono-LightItalic.dart';
import 'RobotoMono-Regular.dart';
import 'RobotoMono-RegularItalic.dart';

VectorFont RobotoMonoFont = VectorFont(defaultWidth: 1230, spaceWidth: 0)
  ..add(RobotoMonoRegularFont())
  ..add(RobotoMonoRegularItalicFont())
  ..add(RobotoMonoBoldFont())
  ..add(RobotoMonoBoldItalicFont())
  ..add(RobotoMonoLightFont())
  ..add(RobotoMonoLightItalicFont());
