import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

class MapCoordinateTransformer 
{
  final TransformationController transformationController;
  final Size imageSize;

  const MapCoordinateTransformer({
    required this.transformationController,
    required this.imageSize,
  });

  // Из экранных координат в координаты изображения
  Vector2 screenToImage(Vector2 screenPoint) {
    final Matrix4 transform = transformationController.value;
    final Matrix4 invertedMatrix = Matrix4.inverted(transform);
    final Vector3 transformed = invertedMatrix.transform3(
      Vector3(screenPoint.x, screenPoint.y, 0)
    );
    return Vector2(transformed.x, transformed.y);
  }

  // Из координат изображения в экранные
  Vector2 imageToScreen(Vector2 imagePoint) {
    final Matrix4 transform = transformationController.value;
    final Vector3 transformed = transform.transform3(
      Vector3(imagePoint.x, imagePoint.y, 0)
    );
    return Vector2(transformed.x, transformed.y);
  }

  // Получить масштабированный размер
  Vector2 getScaledSize() {
    final scale = transformationController.value.getMaxScaleOnAxis();
    return Vector2(imageSize.width * scale, imageSize.height * scale);
  }
}