import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String? username;
  final String? email;
  final String? password;

  const UserEntity({this.userId, this.username, this.email, this.password});

  @override
  List<Object?> get props => [userId, username, email, password];
}
/* Câu hỏi	Trả lời
- Entity là gì?	
Đối tượng business thuần túy — chỉ chứa data fields, không có logic gọi API, không biết database

- Tại sao extends Equatable?	
Để so sánh 2 object theo value (theo props) thay vì theo reference. BLoC cần điều này để biết state có thay đổi hay không

- Tại sao dùng final?
Entity là immutable — tạo xong thì không thay đổi, muốn thay thì tạo object mới

- Tại sao nullable (String?)?	
Vì không phải lúc nào cũng cần đầy đủ fields (ví dụ: khi login chỉ cần email + password) 
*/

/* Entity ← được dùng bởi tất cả các layer khác
  ├── Domain: UseCase trả về Entity
  ├── Data: Model extends Entity
  └── Presentation: BLoC State chứa Entity
*/
