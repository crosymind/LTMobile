import "../db/UserDatabaseHelper.dart";
import "package:app_002/userMS/model/User.dart";
import "package:app_002/userMS/view/AddUserScreen.dart";
import "package:app_002/userMS/view/EditUserScreen.dart";
import "package:app_002/userMS/view/UserListItem.dart";
import "package:flutter/material.dart";
//Stateful widget quan li trang thai (co the thay doi)
class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

//----------------------------------------------------------------------
//State class _UserListScreenState chua logic va giao dien cua man hinh
//class _UserListScreenState extends State<UserListScreen> {}
class _UserListScreenState extends State<UserListScreen> {
  //late: thông báo sau
  //Future: đại diện cho giá trị sẽ có trong tương lai, list<user> kieu du lieu ma future se tra ve
  //Future<List<User>> trong tuong lai co mot danh sach cac doi tuong user
  late Future<List<User>> _usersFuture;

  //@override ghi de phuong thuc tu lop cha (State)
  //super.initState() phải gọi trước khi thực hiện bất kỳ logic nào khác,
  // Đảm bảo các khởi tạo cần thiết từ lớp cha được thực hiện
  //_refreshUsers();
  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = UserDatabaseHelper.instance.getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách người dùng'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
        ],
      ),

      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Không có người dùng nào'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return UserListItem(
                  user: user,
                  onDelete: () async {
                    await UserDatabaseHelper.instance.deleteUser(user.id!);
                    _refreshUsers();
                  },

                  onEdit: () async {
                    // Navigate to edit screen
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserScreen(user: user),
                      ),
                    );
                    if (updated == true) {
                      _refreshUsers();
                    }
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddUserScreen(),
            ),
          );
          if (created == true) {
            _refreshUsers();
          }
        },
      ),
    );
  }
}