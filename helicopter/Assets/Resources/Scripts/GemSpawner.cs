using UnityEngine;
using System.Collections;

public class GemSpawner : MonoBehaviour {

	public GameObject[] prefabs;

	void Start () {
		StartCoroutine(SpawnGems());
	}
	void Update () {

	}

	IEnumerator SpawnGems() {
		while (true) {
			int gemsThisRow = Random.Range(1, 2);
			for (int i = 0; i < gemsThisRow; i++) {
				Instantiate(prefabs[Random.Range(0, prefabs.Length)], new Vector3(26, Random.Range(-10, 10), 10), Quaternion.identity);
			}
			yield return new WaitForSeconds(Random.Range(3, 8));
		}
	}
}
