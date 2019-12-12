/// An Exception raised by the plugin when the user denies a permission
/// Can be thrown by [getWallpaper], [setWallpaper]
/// Use as
/// Example:
/// ```
/// try {
///   // get wallpaper
///   var wallpaper = LauncherUtils.getWallpaper();
/// } on PermissionDeniedException catch (e) {
///   // Show user that the permission is required
///   // Prompt them to grant the permission
///   // Show a settings icon
/// }
/// ```
class PermissionDeniedException implements Exception {
  final message;
  const PermissionDeniedException(this.message);
  @override
  String toString() => "Permission denied: $message";
}
