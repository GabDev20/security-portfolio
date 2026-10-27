# Windows 11 — Diagnóstico e Verificação de Segurança

## 1. Visão geral

**Tipo de atividade:** Suporte técnico, troubleshooting e verificação básica de segurança  
**Sistema operacional:** Windows 11  
**Acesso remoto:** AnyDesk  
**Status:** Verificações básicas concluídas; estabilidade do sistema a acompanhar.

## 2. Problema relatado

Após a instalação do Windows 11 em um computador anteriormente utilizado com Linux, foram relatados os seguintes sintomas:

- Inicialização direcionando para o ambiente de reparo automático do Windows.
- Mensagem de falha no reparo relacionada a `System32\Logfiles\Srt\SrtTrail.txt`.
- Inicialização bem-sucedida em algumas tentativas, com acesso à área de trabalho.
- Novas ocorrências de desligamento após a instalação de aplicativos e personalização do sistema.

**Hipóteses iniciais:**
- Possível corrupção de arquivos do sistema.
- Problemas relacionados à inicialização do Windows.
- Possível falhas no SSD ou HD.
- Possíveis problemas de hardware, temperatura ou alimentação elétrica.

Essas hipóteses não foram confirmadas durante as verificações realizadas.

## 3. Procedimentos executados

### 3.1. Acesso remoto

Foi estabelecida uma sessão de suporte remoto utilizando o AnyDesk para realizar verificações diretamente no computador.

### 3.2. Verificação do Microsoft Defender

**Comando utilizado:**

```powershell
Get-MpComputerStatus
```

**Objetivo:** Consultar o estado do Microsoft Defender Antivirus e dos mecanismos de proteção.

Foram conferidos os seguintes indicadores:

- `AntivirusEnabled`: estado do antivírus.
- `RealTimeProtectionEnabled`: proteção em tempo real.
- `BehaviorMonitorEnabled`: monitoramento comportamental.

**Resultado relatado:** Os indicadores verificados estavam conforme o esperado.

### 3.3. Verificação do Firewall do Windows

**Comando utilizado:**

```powershell
Get-NetFirewallProfile
```

**Objetivo:** Consultar a configuração do firewall nos perfis de rede.

Perfis verificados:

- Domain
- Private
- Public

**Resultado relatado:** Os perfis apresentaram o estado esperado, com o firewall habilitado.

### 3.4. Verificação de integridade dos arquivos do sistema

**Comando utilizado:**

```cmd
sfc /scannow
```

**Objetivo:** Verificar a integridade dos arquivos protegidos do Windows e tentar reparar arquivos corrompidos.

**Observação:** O procedimento foi executado, mas o resultado textual final da ferramenta não foi registrado neste relatório. Portanto, não é possível afirmar que todos os arquivos foram validados ou reparados com sucesso.

### 3.5. Verificação básica do armazenamento

**Comando utilizado:**

```powershell
Get-PhysicalDisk
```

**Objetivo:** Consultar os dispositivos de armazenamento reconhecidos pelo Windows e seus estados reportados.

O principal indicador observado foi `HealthStatus`.

**Resultado relatado:** A verificação foi considerada dentro do esperado.

**Limitação:** Esse comando não substitui testes completos de diagnóstico do fabricante, leitura dos atributos SMART ou testes de superfície do armazenamento.

### 3.6. Monitor de Confiabilidade

**Comando utilizado:**

```text
perfmon /rel
```

**Objetivo:** Abrir o Monitor de Confiabilidade do Windows para consultar falhas de aplicativos, erros do sistema e eventos críticos.

A ferramenta foi indicada para investigar os horários dos desligamentos.

**Observação:** Não foi documentado um resultado conclusivo dessa análise.

## 4. Resumo dos resultados

| Componente | Resultado |
|---|---|
| Microsoft Defender | Indicadores verificados conforme esperado |
| Firewall do Windows | Perfis verificados conforme esperado |
| Arquivos do sistema | Verificação SFC executada; resultado final não registrado |
| Armazenamento | Verificação básica realizada; sem diagnóstico aprofundado documentado |
| Inicialização | Histórico de falhas relatado |
| Desligamentos inesperados | Causa ainda não identificada |

## 5. Avaliação técnica

As verificações realizadas indicaram que as proteções básicas do Windows estavam ativas e que as consultas iniciais não apontaram uma anormalidade evidente no armazenamento.

Entretanto, o histórico de reparo automático e desligamentos inesperados impede concluir que o sistema está totalmente íntegro ou estável.

A ativação do antivírus e do firewall, isoladamente, também não comprova a ausência de malware.

## 6. Próximos passos recomendados

Caso os sintomas voltem a ocorrer:

1. Consultar o Monitor de Confiabilidade (`perfmon /rel`).
2. Analisar os logs do sistema no Visualizador de Eventos (`eventvwr.msc`).
3. Registrar e avaliar o resultado final de `sfc /scannow`.
4. Executar `DISM /Online /Cleanup-Image /RestoreHealth` em um terminal administrativo, se houver suspeita de corrupção da imagem do Windows.
5. Verificar os atributos SMART e executar diagnóstico do SSD/HD.
6. Investigar temperatura, memória RAM, alimentação elétrica e outros componentes se houver desligamentos físicos.
7. Se necessário, avaliar a reinstalação do Windows usando uma mídia de instalação confiável.

## 7. Conclusão

Foi realizada uma verificação inicial de segurança e integridade do Windows 11 por acesso remoto, incluindo Microsoft Defender, Firewall do Windows, SFC, consulta básica ao armazenamento e indicação de análise do Monitor de Confiabilidade.

**Status final:** Verificação básica concluída, com necessidade de acompanhamento da estabilidade.

A causa dos desligamentos e das falhas anteriores de inicialização permanece indeterminada. Não há evidência documentada suficiente para afirmar que o problema foi definitivamente resolvido.

## 8. Tecnologias e ferramentas

- Windows 11
- PowerShell
- Prompt de Comando (CMD)
- Microsoft Defender Antivirus
- Windows Defender Firewall
- System File Checker (SFC)
- Windows Performance Monitor / Reliability Monitor
- AnyDesk

## 9. Boas práticas de segurança

- Não desativar o antivírus ou o firewall sem justificativa técnica.
- Não executar comandos destrutivos sem confirmar o disco e o objetivo.
- Evitar registrar senhas, endereços IP públicos, identificadores pessoais ou dados sensíveis nos relatórios.
- Registrar os resultados reais de cada ferramenta para permitir auditoria e reprodução dos procedimentos.
