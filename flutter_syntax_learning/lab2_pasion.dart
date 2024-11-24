import 'dart:io';

// (Run this by typing 'dart lab2_pasion.dart' in terminal)
void main() {
  print(
      "\n-----------Basic Terminal Input Arithmethic Operator Calculation by Pasion-----------\n");

  stdout.write("Enter the first number: ");
  double? n1 = double.tryParse(stdin.readLineSync()!);

  if (n1 == null) {
    print("Invalid input. Please enter a valid number.");
    return;
  }

  stdout.write("Enter the second number: ");
  double? n2 = double.tryParse(stdin.readLineSync()!);

  if (n2 == null) {
    print("Invalid input. Please enter a valid number.");
    return;
  }

  stdout.write("Choose a basic operation (+, -, *, /): ");
  String? operation = stdin.readLineSync();

  if (operation == null) {
    print("Invalid input. Please enter a valid operation (+, -, *, /).");
    return;
  }

  switch (operation) {
    case '+':
      print("Result (Sum): ${sum(n1, n2)}");
      break;
    case '-':
      print("Result (Difference): ${difference(n1, n2)}");
      break;
    case '*':
      print("Result (Product): ${product(n1, n2)}");
      break;
    case '/':
      if (n2 == 0) {
        print("Error: Division by zero is not allowed.");
      } else {
        print("Result (Quotient): ${quotient(n1, n2)}");
      }
      break;
    default:
      print("Invalid operation. Please choose from (+, -, *, /)");
  }
}

// Function to calculate the arithmetic of two numbers
double sum(double n1, double n2) {
  return n1 + n2;
}

double difference(double n1, double n2) {
  return n1 - n2;
}

double product(double n1, double n2) {
  return n1 * n2;
}

double quotient(double n1, double n2) {
  return n1 / n2;
}
