
// booked => true
// empty => false
import 'dart:io';
List<List<bool>> seats = List.generate(5, (int index)=> List.filled(5, false));
Map<List<int>, Map<String, String>> bookings = {};
void main(){
  print("Welcome to our theater");
  bool flag = true;
  while(flag){
    displayOptions();
    int choice = UserInput();
    switch(choice){
      case 1:
        displaySeats();
        break;
      case 2:
        newBook();
        break;
      case 3:
        displayBookings();
        break;
      case 4:
        print("See you later!");
        flag = false;
        break;
      default:
        print("Invalid choice");
    }
  }

}
int UserInput(){
  return int.parse(stdin.readLineSync()!);
}
String UserInputString(){
  return stdin.readLineSync()!;
}
void displayOptions() {
  print('\n'
      'press 1: to print seats\n'
      'press 2: to book\n'
      'press 3: to print bookings\n'
      'press 4: to exit\n');
}
void displaySeats(){
  for(int i=0;i<seats.length;i++){
    for(int j=0;j<seats[i].length;j++){
      if(seats[i][j]){
        stdout.write("B");
      }else{
        stdout.write("E");
      }
    }
    print("");
  }
}
void  newBook(){
stdout.write("Enter row 1-5:");
int row=int.parse(UserInputString());
stdout.write("Enter column 1-5:");
int col=int.parse(UserInputString());
int r=row-1;
int c=col-1;
if(!seats[r][c]){
  seats[r][c]=true;
  stdout.write("Enter your name:");
  String name=UserInputString();
  stdout.write("Enter your phone number:");
  String phone=UserInputString();
  bookings[[row,col]]={"name":name,"phone":phone};
  print("Seat booked successfully!");
}
else{
  print("Seat already booked!");
}
}
void displayBookings(){
  if(bookings.isEmpty){
    print("No bookings yet!");
  }else{
    bookings.forEach((key, value) {
      print("Seat: Row ${key[0]}, Column ${key[1]}");
      print("Name: ${value['name']}");
      print("Phone: ${value['phone']}");
      print("");
    });
  }
}
