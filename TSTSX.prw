#include 'protheus.ch'
#include 'parmtype.ch'

user function TSTSX()

	RpcSetEnv( '99', '01' )

	OpenSxs(,,,,cEmpAnt,'SX3MDI','SX3',,.F.)
	SX3MDI->(DbSetOrder( 2 ))



return