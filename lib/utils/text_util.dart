String modString(String? text) {
  if (text == null || text.isEmpty) {
    return '';
  }
  String res = '';
  for (var element in text.runes) {
    res += String.fromCharCode(element);
    res += '\u200B';
  }
  return res;
}

RegExp keyWordReg = RegExp(r'\{keyword\}');

RegExp urlReg = RegExp(
    r"^(https?:\/\/(?:www\.)?)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&//=]*)$");
