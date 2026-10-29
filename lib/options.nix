# lib/options.nix — Helpers concisos para criação de opções com documentação obrigatória.
{ lib }:

rec {
  # Cria uma opção genérica com tipo, valor padrão e descrição obrigatória.
  mkOpt =
    type: default: description:
    assert lib.assertMsg (
      description != null && description != ""
    ) "mkOpt: 'description' é obrigatória";
    lib.mkOption {
      inherit type default description;
    };

  # Helper para opções booleanas (ex.: switches de ativação).
  mkBool = default: description: mkOpt lib.types.bool default description;

  # Helper para opções do tipo string.
  mkStr = default: description: mkOpt lib.types.str default description;

  # Helper para opções numéricas inteiras.
  mkInt = default: description: mkOpt lib.types.int default description;

  # Helper para caminhos no filesystem ou store.
  mkPath = default: description: mkOpt lib.types.path default description;

  # Helper para enumerações com lista fixa de valores válidos.
  mkEnum =
    values: default: description:
    mkOpt (lib.types.enum values) default description;

  # Helper para opções do tipo package (derivação).
  mkPkg = default: description: mkOpt lib.types.package default description;

  # Helper para opções do tipo lista com tipo de elementos especificado.
  mkListOf =
    elemType: default: description:
    mkOpt (lib.types.listOf elemType) default description;

  # Helper para opções somente-leitura.
  mkReadOnly =
    type: default: description:
    assert lib.assertMsg (
      description != null && description != ""
    ) "mkReadOnly: 'description' é obrigatória";
    lib.mkOption {
      inherit type default description;
      readOnly = true;
    };
}
