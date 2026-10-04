import 'package:flutter_test/flutter_test.dart';
import 'package:bingo/models/household.dart';
import 'package:bingo/models/community_post.dart';
import 'package:bingo/models/waste_type.dart';
import 'package:bingo/core/utils/date_formatter.dart';

void main() {
  group('BinGo Unit & Smoke Tests', () {
    test('Household model deserialization and getters', () {
      final data = {
        'name': 'Amina Beevi',
        'house': 'Rose Villa',
        'address': 'Kottapuram Road, Ward 4',
        'ward': '4',
        'panchayat': 'Aluva',
        'point': 'Ward 4 Community Depot',
        'email': 'amina@gmail.com',
        'phone': '9846012345',
        'isVerified': true,
        'emailVerified': true,
        'status': 'active',
      };

      final household = Household.fromFirestore('BINGO-001', data);
      expect(household.id, 'BINGO-001');
      expect(household.displayName, 'Amina Beevi');
      expect(household.isFullyVerified, true);
      expect(household.isSuspended, false);
      expect(household.shortInitials, 'AB');
    });

    test('WasteType model fallback colors and guidelines', () {
      final plastic = WasteType.fromFirestore('plastic', {
        'name': 'Dry Plastic',
        'color': '#F59E0B',
        'category': 'dry',
      });

      expect(plastic.name, 'Dry Plastic');
      expect(plastic.isDry, true);
    });

    test('CommunityPost relative time parsing', () {
      final now = DateTime.now();
      final post = CommunityPost(
        id: 'post-1',
        authorUid: 'uid-1',
        authorName: 'John Doe',
        authorHandle: 'johndoe',
        text: 'Neighborhood plastic drive this Sunday!',
        createdAt: now.subtract(const Duration(minutes: 5)),
      );

      expect(post.authorName, 'John Doe');
      expect(post.initials, 'JD');
      expect(post.relativeTime, '5m');
    });

    test('DateFormatter ISO parser works with various formats', () {
      final d1 = DateFormatter.parseLiveDate('2026-10-15');
      expect(d1, isNotNull);
      expect(d1?.year, 2026);
      expect(d1?.month, 10);
      expect(d1?.day, 15);

      final d2 = DateFormatter.parseLiveDate(null);
      expect(d2, isNull);
    });
  });
}
