import 'package:academia_unifor/screens/admin/student_detail_page.dart';
import 'package:academia_unifor/screens/home_screen.dart';
import 'package:academia_unifor/widgets/admin/admin_convex_bottom_bar.dart';
import 'package:academia_unifor/widgets/admin/student_widget.dart';
import 'package:flutter/material.dart';

class StudentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 3,
          child: Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Alunos",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StudentWidget(
                      nome: "João Silva",
                      matricula: "123456",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StudentDetailsPage(
                                  nome: "João Silva",
                                  matricula: "123456",
                                ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    StudentWidget(
                      nome: "Tiago",
                      matricula: "123456",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StudentDetailsPage(
                                  nome: "Tiago",
                                  matricula: "123456",
                                ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    StudentWidget(
                      nome: "Igor",
                      matricula: "123456",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StudentDetailsPage(
                                  nome: "Igor",
                                  matricula: "123456",
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
