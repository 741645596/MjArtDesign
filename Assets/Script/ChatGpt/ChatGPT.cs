using UnityEngine;
using UnityEngine.Networking;
using System.Collections;
using LitJson;


public class ChatGPT : MonoBehaviour
{
    private string API_KEY = "your_openai_api_key";
    private string API_URL = "https://api.openai.com/v1/engines/davinci-codex/completions";

    public void Start()
    {
        // Example usage: generate a response to "Hello, how are you?"
        GenerateResponse("Hello, how are you?");
    }

    public void GenerateResponse(string inputText)
    {
        StartCoroutine(RequestAPI(inputText));
    }

    private IEnumerator RequestAPI(string inputText)
    {
        // Construct the API request payload
        JsonData payload = new JsonData();
        payload["prompt"] = inputText;
        payload["max_tokens"] = 256;
        payload["temperature"] = 0.7f;

        UnityWebRequest request = UnityWebRequest.Post(API_URL, payload.ToString());
        request.SetRequestHeader("Content-Type", "application/json");
        request.SetRequestHeader("Authorization", "Bearer " + API_KEY);

        yield return request.SendWebRequest();

        if (request.result == UnityWebRequest.Result.Success)
        {
            JsonData responseJson = new JsonData(request.downloadHandler.text);
            //string responseText = responseJson.GetField("choices")[0].GetField("text").str;
            //Debug.Log("ChatGPT response: " + responseText);

            // Do something with the response text, e.g. update the Unity scene
        }
        else
        {
            Debug.LogError("ChatGPT API request failed: " + request.error);
        }
    }
}

