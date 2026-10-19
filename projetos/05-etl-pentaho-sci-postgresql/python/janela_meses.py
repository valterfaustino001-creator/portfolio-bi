"""
Reproduz em Python a "janela de meses" que o Pentaho calcula no set_variables.ktr.

Para N meses (3 na rotina diária, 25 na anual), gera:
    MES_nn_INICIO = 1º dia do mês corrente - n meses  (string dd.MM.yyyy, enviada ao Firebird)
    MES_nn_FIM    = último dia desse mês               (string dd.MM.yyyy)
    periodo       = MES_nn_INICIO como date            (gravado no PostgreSQL)
"""
from __future__ import annotations

import calendar
from dataclasses import dataclass
from datetime import date


@dataclass(frozen=True)
class Janela:
    n: int
    inicio: date
    fim: date

    @property
    def inicio_str(self) -> str:
        return self.inicio.strftime("%d.%m.%Y")

    @property
    def fim_str(self) -> str:
        return self.fim.strftime("%d.%m.%Y")


def calcula_janelas(n_meses: int, hoje: date | None = None) -> list[Janela]:
    hoje = hoje or date.today()
    janelas = []
    for n in range(n_meses):
        ano, mes = divmod((hoje.year * 12 + hoje.month - 1) - n, 12)
        mes += 1
        ultimo_dia = calendar.monthrange(ano, mes)[1]
        janelas.append(Janela(n, date(ano, mes, 1), date(ano, mes, ultimo_dia)))
    return janelas


def variaveis_pdi(n_meses: int, hoje: date | None = None) -> dict[str, str]:
    """Mesmo dicionário de variáveis que o PDI cria (escopo ROOT_JOB)."""
    out = {}
    for j in calcula_janelas(n_meses, hoje):
        out[f"MES_{j.n:02d}_INICIO"] = j.inicio_str
        out[f"MES_{j.n:02d}_FIM"] = j.fim_str
    return out


if __name__ == "__main__":
    # Exemplo confirmado no log do Pentaho, execução em 10/03/2026
    for k, v in variaveis_pdi(3, date(2026, 3, 10)).items():
        print(f"{k:15} = {v}")
