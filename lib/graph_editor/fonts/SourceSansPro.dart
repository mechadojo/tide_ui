import 'vector_font.dart';

import 'SourceSansPro-Bold.dart';
import 'SourceSansPro-BoldItalic.dart';
import 'SourceSansPro-Light.dart';
import 'SourceSansPro-LightItalic.dart';
import 'SourceSansPro-Regular.dart';
import 'SourceSansPro-RegularItalic.dart';

VectorFont SourceSansProFont = VectorFont(defaultWidth: 25)
  ..add(SourceSansProRegularFont())
  ..add(SourceSansProRegularItalicFont())
  ..add(SourceSansProBoldFont())
  ..add(SourceSansProBoldItalicFont())
  ..add(SourceSansProLightFont())
  ..add(SourceSansProLightItalicFont());
