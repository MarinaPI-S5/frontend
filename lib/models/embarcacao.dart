abstract class Embarcacao {
  final String embarcacao;
  final String dono;
  final String telefone;

  Embarcacao({
    required this.embarcacao,
    required this.dono,
    required this.telefone,
  });
}

class EmbarcacaoCadastrada extends Embarcacao {
  EmbarcacaoCadastrada({
    required super.embarcacao,
    required super.dono,
    required super.telefone,
  });
}

final List<EmbarcacaoCadastrada> listaEmbarcacoesMock = [
  EmbarcacaoCadastrada(
    embarcacao: 'Lancha Ventura 250',
    dono: 'Roberto Almeida',
    telefone: '(11) 98765-4321',
  ),
  EmbarcacaoCadastrada(
    embarcacao: 'Veleiro Fast 310',
    dono: 'Fernanda Oliveira',
    telefone: '(21) 99876-5432',
  ),
  EmbarcacaoCadastrada(
    embarcacao: 'Lancha Focker 255',
    dono: 'Ricardo Souza',
    telefone: '(48) 99123-4567',
  ),
  EmbarcacaoCadastrada(
    embarcacao: 'Jet Ski Yamaha FX',
    dono: 'Lucas Ferreira',
    telefone: '(13) 98234-5678',
  ),
  EmbarcacaoCadastrada(
    embarcacao: 'Lancha Real 275',
    dono: 'Eduardo Mendes',
    telefone: '(24) 99345-6789',
  ),
  EmbarcacaoCadastrada(
    embarcacao: 'Veleiro Delta 36',
    dono: 'Ana Beatriz Lima',
    telefone: '(71) 98456-7890',
  ),
  EmbarcacaoCadastrada(
    embarcacao: 'Lancha Triton 300',
    dono: 'Marcelo Ribeiro',
    telefone: '(47) 99567-8901',
  ),
  EmbarcacaoCadastrada(
    embarcacao: 'Jet Ski Sea-Doo GTX',
    dono: 'Patrícia Rocha',
    telefone: '(22) 98678-9012',
  ),
  EmbarcacaoCadastrada(
    embarcacao: 'Lancha Coral 27',
    dono: 'Bruno Carvalho',
    telefone: '(81) 99789-0123',
  ),
  EmbarcacaoCadastrada(
    embarcacao: 'Lancha Schaefer 303',
    dono: 'Sérgio Gomes',
    telefone: '(41) 98890-1234',
  ),
];
