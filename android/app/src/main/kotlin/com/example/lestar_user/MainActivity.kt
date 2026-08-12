package id.lestari.user

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "id.lestari.user/gallery_saver"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImageToGallery" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    val albumName = call.argument<String>("albumName") ?: "Lestari"

                    if (bytes == null || bytes.isEmpty() || fileName.isNullOrBlank()) {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Image bytes and fileName are required.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        result.success(saveImageToGallery(bytes, fileName, albumName))
                    } catch (exception: Exception) {
                        result.error(
                            "SAVE_FAILED",
                            exception.message ?: "Unable to save image.",
                            null
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveImageToGallery(
        bytes: ByteArray,
        fileName: String,
        albumName: String
    ): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveImageWithMediaStore(bytes, fileName, albumName)
        } else {
            saveLegacyImage(bytes, fileName, albumName)
        }
    }

    private fun saveImageWithMediaStore(
        bytes: ByteArray,
        fileName: String,
        albumName: String
    ): String {
        val resolver = applicationContext.contentResolver
        val imageCollection = MediaStore.Images.Media.getContentUri(
            MediaStore.VOLUME_EXTERNAL_PRIMARY
        )
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            put(
                MediaStore.Images.Media.RELATIVE_PATH,
                "${Environment.DIRECTORY_PICTURES}${File.separator}$albumName"
            )
            put(MediaStore.Images.Media.IS_PENDING, 1)
        }
        val imageUri = resolver.insert(imageCollection, values)
            ?: throw IllegalStateException("Unable to create gallery item.")

        try {
            resolver.openOutputStream(imageUri)?.use { outputStream ->
                outputStream.write(bytes)
            } ?: throw IllegalStateException("Unable to open gallery item.")

            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(imageUri, values, null, null)
            return imageUri.toString()
        } catch (exception: Exception) {
            resolver.delete(imageUri, null, null)
            throw exception
        }
    }

    private fun saveLegacyImage(
        bytes: ByteArray,
        fileName: String,
        albumName: String
    ): String {
        val picturesDirectory = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_PICTURES
        )
        val albumDirectory = File(picturesDirectory, albumName)
        if (!albumDirectory.exists() && !albumDirectory.mkdirs()) {
            throw IllegalStateException("Unable to create gallery directory.")
        }

        val imageFile = File(albumDirectory, fileName)
        FileOutputStream(imageFile).use { outputStream ->
            outputStream.write(bytes)
        }
        MediaScannerConnection.scanFile(
            applicationContext,
            arrayOf(imageFile.absolutePath),
            arrayOf("image/png"),
            null
        )
        return imageFile.absolutePath
    }
}
