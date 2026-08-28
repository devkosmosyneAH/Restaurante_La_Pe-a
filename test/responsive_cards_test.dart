import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/Presentation/core/domain/enums.dart';
import 'package:restaurant_app/Presentation/entities/clientes/cliente.dart';
import 'package:restaurant_app/Presentation/entities/usuarios/usuario.dart';
import 'package:restaurant_app/Presentation/widgets/clientes/cliente_card.dart';
import 'package:restaurant_app/Presentation/widgets/usuarios/usuario_card.dart';

void main() {
  testWidgets('client and user cards fit a compact viewport', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previousHandler);

    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime(2024);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView(
          children: [
            ClienteCard(
              cliente: Cliente(
                cedula: '0102030405',
                restaurantId: 'rest-1',
                nombre: 'Nombre de cliente con texto largo',
                apellido: 'Apellido extenso',
                telefono: '+593 999 999 999',
                email: 'cliente.con.correo.muy.largo@example.com',
                createdAt: now,
                updatedAt: now,
              ),
              onEdit: () {},
              onDelete: () {},
              onVerResumen: () {},
            ),
            UsuarioCard(
              usuario: Usuario(
                id: 'user-1',
                restaurantId: 'rest-1',
                nombre: 'Usuario con nombre largo',
                email: 'usuario.con.correo.muy.largo@example.com',
                pin: '1234',
                rol: RolUsuario.administrador,
                createdAt: now,
                updatedAt: now,
              ),
              onEdit: () {},
              onDelete: () {},
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      errors.where(
        (details) => details.exceptionAsString().contains('overflow'),
      ),
      isEmpty,
    );
  });
}
