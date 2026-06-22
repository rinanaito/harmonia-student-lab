import 'package:web/web.dart' as web;

void openNewTab(String url) {
  web.window.open(url, '_blank', 'noopener,noreferrer');
}
