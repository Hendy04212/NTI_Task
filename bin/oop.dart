

class Task {
  String? creratedAt;
  String? discription;
  String? image_path;
  late int id;

  Task({ required this.id, this.discription, this.creratedAt, this.image_path}){
  }
  Task.catA({ required this.id, this.discription, this.creratedAt, this.image_path}){
  }
  Task.fromJson(Map<String, dynamic> json){
    id = json['id'] ?? 0;
    discription = json['discription'] ?? "Unknown";
    creratedAt = json['created_at'] ?? "Unknown";
    image_path = json['image_path'] ?? null;
  }

   Map<String, dynamic> toJson(){
    return {
      'id': id,
      'discription': discription,
      'created_at': creratedAt,
      'image_path': image_path
    };
   }



  void display(){
    print("ID: $id");
    print("Description: ${discription ?? "Unknown"}");
    print("Created At: $creratedAt");
      if(image_path != null){
        print("Image Path: $image_path");
      } else {
        print("No image available");
      }
      }
}
void main(){
  Task t1 = Task(id: 1, discription: "Task 1", creratedAt: "2026-06-01");
  Task t2 = Task.catA(id: 2, discription: "Task 2", creratedAt: "2026-06-02");
  t1.display();
  t2.display();

  // Book b1 = Book.catA( name: 'book 1' );
  // Book b2 = Book.catA(name: 'book 2');
  // b2 = b1;
  // b1.name = "book 3";
  // b2.name = "book 4";
  // print(b1 == b2);
  // print(b1.name );
  // print(b2.name );

  
// var bookMap = {
//   "name": "book 1",
//   "author": "author 1",
//   "price": 100.0,
//   "category": "A"
// };
// Book b4 = Book(name: bookMap['name'], author: bookMap['author'], price: bookMap['price'], category: bookMap['category']);

// Map<String, dynamic> bookJson ={
//   'name': b4.name,
//   'author': b4.author,
//   'price': b4.price,
//   'category': b4.category
// };
// Book b3 = Book.fromJson(bookMap);
// b3.display();


  // b1.display();
  // b2.display();
}
