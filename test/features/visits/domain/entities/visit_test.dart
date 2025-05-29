import 'package:flutter_test/flutter_test.dart';
import 'package:visitstracker/features/visits/domain/entities/visit.dart';

void main() {
  group('Visit Entity Tests', () {
    test('should create a Visit with all required fields', () {
      // Arrange
      final now = DateTime.now();
      final visit = Visit(
        id: 1,
        customerId: 1,
        visitDate: now,
        status: 'Completed',
        location: 'Test Location',
        notes: 'Test Notes',
        activitiesDone: ['1', '2'],
        createdAt: now,
      );

      // Assert
      expect(visit.id, equals(1));
      expect(visit.customerId, equals(1));
      expect(visit.visitDate, equals(now));
      expect(visit.status, equals('Completed'));
      expect(visit.location, equals('Test Location'));
      expect(visit.notes, equals('Test Notes'));
      expect(visit.activitiesDone, equals(['1', '2']));
      expect(visit.createdAt, equals(now));
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      final now = DateTime.now();
      final visit1 = Visit(
        id: 1,
        customerId: 1,
        visitDate: now,
        status: 'Completed',
        location: 'Test Location',
        notes: 'Test Notes',
        activitiesDone: ['1'],
        createdAt: now,
      );

      final visit2 = Visit(
        id: 1,
        customerId: 1,
        visitDate: now,
        status: 'Completed',
        location: 'Test Location',
        notes: 'Test Notes',
        activitiesDone: ['1'],
        createdAt: now,
      );

      // Assert
      expect(visit1, equals(visit2));
      expect(visit1.hashCode, equals(visit2.hashCode));
    });

    test('should not be equal when properties are different', () {
      // Arrange
      final now = DateTime.now();
      final visit1 = Visit(
        id: 1,
        customerId: 1,
        visitDate: now,
        status: 'Completed',
        location: 'Test Location',
        notes: 'Test Notes',
        activitiesDone: ['1'],
        createdAt: now,
      );

      final visit2 = Visit(
        id: 2, // Different ID
        customerId: 1,
        visitDate: now,
        status: 'Completed',
        location: 'Test Location',
        notes: 'Test Notes',
        activitiesDone: ['1'],
        createdAt: now,
      );

      // Assert
      expect(visit1, isNot(equals(visit2)));
      expect(visit1.hashCode, isNot(equals(visit2.hashCode)));
    });
  });
}
