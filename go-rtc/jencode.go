// This file does not use encoding/json Marshal because we believe string operation is faster;
package main

import "fmt"

func getConnectMessage(sessionid string) []byte {
	if len(TURN) == 0 {
		return []byte(fmt.Sprintf(`{"event":"connect","data":{"sessionid":"%s","stunservers":[{"url":"%s"}],"turnservers":[]}}`, sessionid, STUN))
	}
	return []byte(fmt.Sprintf(`{"event":"connect","data":{"sessionid":"%s","stunservers":[{"url":"%s"}],"turnservers":["url":"%s"]}}`, sessionid, STUN, TURN))
}

func getRemoveFeedMessage(sessionid string, tp string) []byte {

	return []byte(fmt.Sprintf(`{"event":"remove","data":{"id":"%s","type":"%s"}}`, sessionid, tp))
}

func getRemoveClientMessage(sessionid string) []byte {
	return []byte(fmt.Sprintf(`{"event":"remove","data":{"id":"%s"}}`, sessionid))
}
