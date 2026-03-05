import 'package:faker/faker.dart';
import '../../features/user/entities/user.dart';

final faker = Faker();

class FakeUsers {
  static List<User> generate({int count = 5}) {
    return List.generate(count, (index) {
      return User(
        id: 'user_$index',
        name: faker.person.name(),
        email: faker.internet.email(),
        createdAt: faker.date.dateTime(minYear: 2020, maxYear: 2024)
      );
    });
  }
}