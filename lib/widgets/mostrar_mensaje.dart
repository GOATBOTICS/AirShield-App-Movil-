import 'package:airshield/util/responsive.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

Future<dynamic> mostrarMensajeError(
  BuildContext context,
  String titulo,
  String descripcion,
) {
  return AwesomeDialog(
    width: Responsive.isDesktop(context) || Responsive.isTablet(context)
        ? 400
        : null,
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.rightSlide,
    headerAnimationLoop: false,
    title: titulo,
    desc: descripcion,
    btnOkOnPress: () {},
    btnOkIcon: Icons.cancel,
    btnOkColor: Colors.red,
  ).show();
}

Future<dynamic> mostrarMensajeCorrecto(
  BuildContext context,
  String titulo,
  String descripcion,
  Function btnOkOnPress,
  Function onDismissCallback,
) {
  return AwesomeDialog(
    width: Responsive.isDesktop(context) || Responsive.isTablet(context)
        ? 400
        : null,
    context: context,
    animType: AnimType.leftSlide,
    headerAnimationLoop: false,
    dialogType: DialogType.success,
    showCloseIcon: true,
    title: titulo,
    desc: descripcion,
    btnOkOnPress: () => btnOkOnPress,
    btnOkIcon: Icons.check_circle,
    onDismissCallback: (type) => onDismissCallback,
  ).show();
}

Future<dynamic> confirmar(
  BuildContext context,
  String titulo,
  String descripcion,
  Function onConfirm,
  Function onCancel,
) {
  return AwesomeDialog(
    width: Responsive.isDesktop(context) || Responsive.isTablet(context)
        ? 400
        : null,
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.topSlide,
    headerAnimationLoop: false,
    title: titulo,
    desc: descripcion,
    btnOkText: 'Confirmar',
    btnCancelText: 'Cancelar',
    btnOkOnPress: () {
      onConfirm(); // Acción a ejecutar al confirmar
    },
    btnCancelOnPress: () {
      onCancel(); // Acción a ejecutar al cancelar
    },
    onDismissCallback: (type) {
      // Acción cuando el diálogo se cierra sin presionar botones
      if (type == DismissType.btnCancel || type == DismissType.other) {
        onCancel();
      }
    },
  ).show();
}

Future<dynamic> infoConfirmDialog(
  BuildContext context, {
  required String titulo,
  String? descripcion,
  Function? onOk,
  Function? onCancel,
  String btnOkText = "Si",
  String btnCancelText = "No",
  bool mostrarCerrarIcon = true,
  Color? colorOk,
  Color? colorCancel,
}) {
  return AwesomeDialog(
    width: Responsive.isDesktop(context) || Responsive.isTablet(context)
        ? 400
        : null,
    context: context,
    dialogType: DialogType.info,
    animType: AnimType.bottomSlide,
    headerAnimationLoop: false,
    title: titulo,
    desc: descripcion,
    showCloseIcon: mostrarCerrarIcon,
    btnOkText: btnOkText,
    btnCancelText: btnCancelText,
    btnOkOnPress: () {
      if (onOk != null) onOk();
    },
    btnCancelOnPress: () {
      if (onCancel != null) onCancel();
    },
    btnOkColor: colorOk ?? Colors.blue,
    btnCancelColor: colorCancel ?? Colors.red,
  ).show();
}
