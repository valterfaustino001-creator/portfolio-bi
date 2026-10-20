# Como importar e configurar o atendimento no n8n

Importe cada um dos três JSONs em um workflow separado. A importação coloca os nós no editor; credenciais, banco e integrações ainda precisam ser configurados. Mantenha os fluxos desativados até concluir a homologação.

## 1 Baixar os arquivos

No GitHub, abra cada arquivo abaixo e use **Download raw file**. Se o navegador exibir o conteúdo, salve o arquivo com extensão `.json`, sem adicionar `.txt`.

- [Disparo inicial](01-disparo.referencia.json)
- [Atendimento](02-atendimento.referencia.json)
- [Expiração](03-expiracao.json)
- [Banco de dados](schema.sql)

Alternativamente, na página inicial do repositório, clique em **Code → Download ZIP**, extraia o ZIP e entre em `projetos/08-atendimento-whatsapp-n8n`.

## 2 Importar o primeiro workflow

1. Entre na sua instância do n8n.
2. Abra **Workflows** no projeto onde deseja salvar a automação.
3. Clique em **Create Workflow** ou **Add workflow**, conforme a versão.
4. No editor, abra o menu **⋯** do workflow, na parte superior.
5. Selecione **Import from File**.
6. Escolha `01-disparo.referencia.json`.
7. Confira se os nós apareceram e salve. Se sua versão salvar automaticamente, confirme o indicador de salvamento.
8. Mantenha o workflow sem publicar ou com **Active** desligado, conforme sua versão.

Repita o procedimento em **dois workflows novos** para `02-atendimento.referencia.json` e `03-expiracao.json`. Não importe os três sobre o mesmo editor.

O menu e a importação de arquivo são descritos na [documentação oficial do n8n](https://docs.n8n.io/workflows/export-import/). A opção **Import from URL** também existe, mas exige o endereço do JSON bruto, não a página `github.com/.../blob/...`.

## 3 Preparar o PostgreSQL

1. Use um banco de aplicação próprio para a automação, separado das tabelas internas do n8n.
2. Abra o editor SQL do seu provedor, pgAdmin ou ferramenta equivalente.
3. Cole o conteúdo de `schema.sql` e execute uma vez.
4. Confirme que existem as tabelas `wa_sessions`, `wa_events`, `wa_campaigns`, `wa_phone_locks`, `wa_outbox` e `wa_delivery`, além da função `wa_try_lock`.
5. No n8n, crie uma credencial **Postgres**, preenchendo host, database, usuário, senha, porta e SSL conforme seu provedor.
6. Teste a conexão e selecione essa credencial em todos os nós Postgres dos três workflows.

Não cole o SQL em **Import from File**: essa opção é para workflows JSON. Criar as tabelas outbox/locks não implementa automaticamente os workers de produção.

## 4 Preparar o Google Sheets

Crie uma aba chamada **Contatos**, com estes cabeçalhos na primeira linha:

```text
nome | telefone | codigo_pedido | status_envio | data_ultimo_contato | opt_in | data_opt_in | origem_opt_in | opt_out | bot_paused | erro_envio | wamid
```

Cada nome deve ocupar uma coluna, sem os caracteres `|`. Formate telefone e código do pedido como texto simples. Use uma linha por telefone, com DDI e somente dígitos. Para o teste, use seu número autorizado, `opt_in=sim`, `opt_out=não`, `bot_paused=não` e status vazio.

Em cada nó Google Sheets:

1. Selecione uma credencial **Google Sheets OAuth2**, conectada à conta com acesso à planilha.
2. Substitua `PREENCHER_SPREADSHEET_ID` pelo ID do documento. Ele fica entre `/d/` e `/edit` na URL do Google Sheets.
3. Selecione a aba **Contatos**.
4. Recarregue os campos/colunas, se solicitado.
5. Nos nós de atualização, confira **Column to match on = telefone**.
6. Preserve as expressões já existentes em status, data, opt-out e demais campos.

O projeto usa a API Google Sheets para ler o conteúdo do arquivo armazenado no Google Drive.

## 5 Configurar o WhatsApp

Você precisa de um app Meta configurado com WhatsApp, número da Cloud API, token de acesso válido e um template aprovado.

Nos nós **Configuracao** dos workflows 01 e 02, preencha:

| Campo | O que informar |
|---|---|
| `graph_version` | Versão suportada pelo seu app, no formato `vNN.N` |
| `phone_number_id` | ID do número na Meta; não é o telefone nem o WABA ID |
| `template` | Nome exato do template aprovado |
| `language` | Código do idioma aprovado, por exemplo `pt_BR` |
| `campaign_id` | Identificador fixo da campanha lógica |

Para **Enviar template**, **Enviar resposta** e **Enviar texto alternativo**, crie uma credencial **Header Auth**:

- **Name:** `Authorization`
- **Value:** `Bearer SEU_TOKEN_DA_META`

Selecione a credencial no nó HTTP Request. Guarde o token somente na credencial, sem colocar o valor no código ou no GitHub.

No **WhatsApp Trigger**, selecione a credencial WhatsApp OAuth2 com os dados do app e mantenha o evento **Messages**. Verifique a assinatura dos webhooks na configuração/versão instalada. Use HTTPS acessível pela Meta.

O texto do template está na seção 8 do [guia técnico](GUIA.html). O JSON envia um parâmetro de nome; o template aprovado precisa ter a mesma estrutura e idioma. Trocar o nome do template não adapta automaticamente seus parâmetros.

## 6 Configurar pagamento, logística e vendedor

No **Configuracao** do workflow 02:

1. Troque `pagamento` pelas condições reais de Pix, cartão, boleto, parcelas e prazos.
2. Preencha `tracking_url` e `shipping_url` com os endpoints dos seus adaptadores. Os endereços `.example` são placeholders e não funcionam.
3. Confira os contratos de entrada/saída na seção 6 do guia. Rastreamento precisa validar o vínculo entre pedido e telefone; frete precisa de origem, peso e dimensões além do CEP.
4. Associe credenciais próprias de logística aos dois nós de consulta. Não use o token Meta nesses serviços.
5. Preencha `vendedor_email`.
6. No nó **Email para vendedor**, configure o remetente e uma credencial SMTP válida.

O vendedor precisa de uma caixa de atendimento conectada ao número da Cloud API para responder ao cliente. O e-mail apenas avisa que o atendimento foi transferido.

## 7 Fazer um teste controlado

1. Use um app/número de homologação e somente seu contato na planilha.
2. Teste primeiro as conexões Postgres e Sheets.
3. No workflow 01, clique em **Execute Workflow**. Essa ação pode enviar uma mensagem real ao telefone elegível.
4. Confirme o recebimento do template e o preenchimento de `status_envio=enviado`, data e `wamid`.
5. Coloque o workflow 02 no modo de recebimento de teste do Trigger conforme sua versão, ou publique-o no ambiente de homologação. Responda ao template.
6. Confira o menu, pagamento, pedido, CEP, texto desconhecido e encaminhamento humano.
7. Teste “sair” em outro contato de teste ou por último: o opt-out é persistente e bloqueia as próximas mensagens automáticas.
8. Confira falhas e dados recebidos na aba **Executions**.

O teste e a produção não devem disputar o mesmo app Meta: alternar o webhook de teste pode substituir o de produção. Não clique em executar o disparo repetidamente para tentar resolver um timeout; o envio pode ter sido aceito mesmo sem resposta de rede.

## 8 Publicar depois da homologação

Antes de tráfego real, implemente a camada de fila, lock por telefone e recuperação descrita na seção 9 do guia. Os JSONs publicados são referências e ainda não incluem essa camada completa.

Quando a configuração e os testes estiverem concluídos:

1. Publique/ative o workflow 02 e confirme que o webhook de produção está registrado na Meta.
2. Publique/ative o workflow 03 para expirar sessões.
3. Execute o workflow 01 manualmente para o lote autorizado. Ele não possui agendamento automático; publicar sozinho não dispara a lista.
4. Se quiser um horário recorrente, substitua o Manual Trigger por Schedule Trigger somente depois de definir a política de campanhas e a cadência global.

Importar JSON não executa `schema.sql`, não aprova template, não transfere credenciais e não conecta as APIs automaticamente.

## Problemas comuns

| Sintoma | Verificação |
|---|---|
| Nó com alerta de credencial | Escolha a credencial no próprio nó e teste a conexão |
| Colunas não aparecem | Selecione documento/aba e recarregue o schema |
| Não há contatos para enviar | Confira opt_in, status, supressão e reserva da campanha; não apague reservas incertas para forçar reenvio |
| Template rejeitado | Confira aprovação, nome, idioma, categoria e parâmetros |
| Bot não recebe respostas | Confira número, app, HTTPS, assinatura e webhook teste/produção |
| Consulta de frete falha | Substitua endpoint placeholder e valide dados do pacote |
| Bot fica em silêncio | Confira opt_out ou transferência humana antes de alterar a lógica |
| Nó desconhecido na importação | Compare sua versão n8n com o tipo/versão do nó no JSON e atualize ou reconfigure esse nó em homologação |

Veja também [credenciais WhatsApp no n8n](https://docs.n8n.io/integrations/builtin/credentials/whatsapp/) e [comportamento do WhatsApp Trigger](https://docs.n8n.io/integrations/builtin/trigger-nodes/n8n-nodes-base.whatsapptrigger/).
