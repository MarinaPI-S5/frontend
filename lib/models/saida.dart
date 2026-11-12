import 'package:frontend/models/embarcacao.dart';
import 'package:intl/intl.dart';

class Saida extends Embarcacao {
  String responsavel;
  DateTime horarioSaidaBruto;
  DateTime horarioPrevistoBruto;
  DateTime? horarioRetornoBruto;

  Saida({
    required super.embarcacao,
    required super.dono,
    required super.telefone,
    required this.responsavel,
    required this.horarioSaidaBruto,
    required this.horarioPrevistoBruto,
    this.horarioRetornoBruto,
  });

  List<String> formatarHorarios(List<DateTime?> horarios) {
    final formatador = DateFormat('HH:mm');

    return horarios.map((horario) {
      if (horario == null) return '--:--';
      return formatador.format(horario);
    }).toList();
  }

  late final List<String> _horariosFormatados = formatarHorarios([
    horarioSaidaBruto,
    horarioPrevistoBruto,
    horarioRetornoBruto,
  ]);

  String get horarioSaida => _horariosFormatados[0];
  String get horarioPrevisto => _horariosFormatados[1];
  String get horarioRetorno => _horariosFormatados[2];
}

final List<Saida> listaSaidasMock = [
  Saida(
    embarcacao: 'Lancha Ventura 250',
    dono: 'Roberto Almeida',
    telefone: '(11) 99999-1111',
    responsavel: 'Carlos Henrique',
    horarioSaidaBruto: DateTime(2026, 11, 12, 9, 30),
    horarioPrevistoBruto: DateTime(2026, 11, 12, 12, 30),
    horarioRetornoBruto: DateTime(2026, 11, 12, 12, 15),
  ),

  Saida(
    embarcacao: 'Focker 255',
    dono: 'Marcos Oliveira',
    telefone: '(11) 98888-2222',
    responsavel: 'Pedro Santos',
    horarioSaidaBruto: DateTime(2026, 11, 12, 10, 0),
    horarioPrevistoBruto: DateTime(2026, 11, 12, 13, 0),
  ),

  Saida(
    embarcacao: 'Schaefer 303',
    dono: 'Fernando Costa',
    telefone: '(11) 97777-3333',
    responsavel: 'Lucas Ferreira',
    horarioSaidaBruto: DateTime(2026, 11, 12, 8, 0),
    horarioPrevistoBruto: DateTime(2026, 11, 12, 11, 0),
    horarioRetornoBruto: DateTime(2026, 11, 12, 11, 20),
  ),

  Saida(
    embarcacao: 'NX 260',
    dono: 'André Martins',
    telefone: '(11) 96666-4444',
    responsavel: 'Gabriel Souza',
    horarioSaidaBruto: DateTime(2026, 11, 12, 11, 30),
    horarioPrevistoBruto: DateTime(2026, 11, 12, 15, 30),
  ),

  Saida(
    embarcacao: 'Phantom 300',
    dono: 'Ricardo Mendes',
    telefone: '(11) 95555-5555',
    responsavel: 'Matheus Lima',
    horarioSaidaBruto: DateTime(2026, 11, 12, 7, 30),
    horarioPrevistoBruto: DateTime(2026, 11, 12, 10, 30),
    horarioRetornoBruto: DateTime(2026, 11, 12, 10, 45),
  ),
];
