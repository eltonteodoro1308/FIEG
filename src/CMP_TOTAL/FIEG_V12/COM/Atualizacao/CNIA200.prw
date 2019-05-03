#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CNIA200   �Autor  �Fabricio Romera     � Data �  10/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Exibe consulta especifica para visualizacao das avaliacoes ���
���          � de um fornecedor.      									  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CNIA200(cFornec, cLoja)
Local aArea   := GetArea()
Local cFiltro := ""

Default cFornec := ""
Default cLoja	:= ""

	//Define filtro conforme parametros
	cFiltro := "PA6_FORNEC = '" + cFornec + "' AND PA6_LOJA = '" + cLoja + "'"
	
	//Exibe tela de para consulta
	U_CNIA188AF(.T., cFiltro)

RestArea(aArea)
Return