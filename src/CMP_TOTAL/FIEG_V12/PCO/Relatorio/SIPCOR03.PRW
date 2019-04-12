#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOR03
Relatorio de criticas de importacao de planilhas.

@type function
@author TOTVS
@since 27/09/2011
@version P12.1.23

@param _aDados, Numérico, Dados do Relatório.
@param _cFile, Numérico, Arquivo.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOR03(_aDados,_cFile)

Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := "Relatório de Inconsistências"
Local cPict         := ""
Local titulo        := "Relatório de Inconsistências ( "+Alltrim(Upper(_cFile))+" )"
Local nLin          := 80
Local Cabec1        := "Linha  Campo       Conteudo                                             Descrição"
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd          := {}
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "SIPCOR03" 							// Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "SIPCOR03" 							// Coloque aqui o nome do arquivo usado para impressao em disco
Private cString     := "AK2"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Monta a interface padrao com o usuario >--------------
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//--< Processamento. RPTSTATUS monta janela com a regua de processamento. >--

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,_aDados) },Titulo)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOR03
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.

@type function
@author TOTVS
@since 27/09/2011
@version P12.1.23

@param Cabec1, Caractere, Cabeçalho do Relatório.
@param Cabec2, Caractere, Cabeçalho do Relatório.
@param Titulo, Caractere, Título do Relatório.
@param nLin, Numérico, Numero da Linha.
@param _aDados, Array, Dados do Relatório.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,_aDados)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Impressao do cabecalho do relatorio >-----------------
If nLin > 55 												// Salto de Página. Neste caso o formulario tem 55 linhas...
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
Endif

For i := 1 to Len(_aDados)
	
	@nLin,000 PSAY StrZero(_aDados[i,1],5)
	@nLin,007 PSAY _aDados[i,2]
	@nLin,019 PSAY Left(_aDados[i,3],50)
	@nLin,072 PSAY _aDados[i,4]
	
	nLin++
	
	If nLin > 55 											// Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
Next

//--< Finaliza a execucao do relatorio >--------------------
SET DEVICE TO SCREEN

//--< Se impressao em disco, chama o gerenciador de impressao >--
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return
