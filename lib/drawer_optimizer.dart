import 'dart:io';

void main() async {
  final file = File(r'c:\Users\Roberto\Desktop\PROYECTOS\sistema prestamos\prestamos_app\lib\presentation\widgets\app_drawer.dart');
  var content = await file.readAsString();

  content = content.replaceFirst("return Drawer(", "return RepaintBoundary(\n      child: Drawer(");
  // Find the end of the return statement for Drawer
  var lastIndex = content.lastIndexOf(");");
  if (lastIndex != -1) {
     content = content.substring(0, lastIndex) + ",\n    );" + content.substring(lastIndex + 2);
  }
  
  // Agregar la optimización de pop para el drawer
  content = content.replaceAll("onTap: onTapOverride ?? () {", 
      "onTap: onTapOverride ?? () {\n        if (selected) {\n          Navigator.pop(context);\n          return;\n        }\n");
      
  content = content.replaceAll(r"Navigator.pop(context);", r"Navigator.pop(context);");
  content = content.replaceAll(r"Future.delayed(const Duration(milliseconds: 100), () {", r"WidgetsBinding.instance.addPostFrameCallback((_) { if(context.mounted) {");
  
  await file.writeAsString(content);
  print('Updated AppDrawer safely');
}
