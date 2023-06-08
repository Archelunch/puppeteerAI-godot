extends Node

@export var OPENAI_KEY = ""
@export var bart_url = "http://127.0.0.1:8000/resolve"
@export var datasources: Array[String] = []
const openai_url = "https://api.openai.com/v1/completions"

var headers
var current_speaker = ""
var current_target = ""

var default_schema = {
  "model": "text-davinci-003",	
  "prompt": "",
  "temperature": 0.85,
  "max_tokens": 15,
  "top_p": 1,
  "frequency_penalty": 0,
  "presence_penalty": 0,
  "stop": ["\n"]
}

func _ready():
	$GPTRequest.request_completed.connect(self._gpt_request_completed)
	$BARTRequest.request_completed.connect(self._bart_request_completed)
	headers  = ["Content-Type: application/json", "Authorization: Bearer " + OPENAI_KEY]

func request_GPT(prompt, unit_name, target_name, temperature=0.85, max_tokens=15, suffix=""):
	var body_dict = {
		"prompt": prompt,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"model": "text-davinci-003",
		"stop": ["\n"]
	}
	
	if suffix != "":
		body_dict['suffix'] = suffix
	var body = JSON.new().stringify(body_dict)
	current_speaker = unit_name
	current_target = target_name
	var error = $GPTRequest.request(openai_url, headers, HTTPClient.METHOD_POST, body)
	

func request_bart(unit_id, prompt, choices, serialized_actions, multi_action=true):
	var body = JSON.new().stringify({
		"unit_id": unit_id,
		"situation": prompt,
		"actions": choices,
		"multi_action": multi_action,
		"additional_data": JSON.new().stringify(serialized_actions)
	})
	var error = $BARTRequest.request(bart_url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)


func _gpt_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	if json.get_data().has("choices"):
		var response = json.get_data()['choices'][0]['text']
		EventBus.publish("gpt_result", {'text': response, 'unit': current_speaker})
		var generated_text = '{from} said to {to}: {phrase}"'.format({'from':current_speaker, 'to':current_target, 'phrase':response})
		EventBus.publish("update_battle_log", generated_text)
		current_speaker = ""


func _bart_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if response:
		response.erase("sequence")
		EventBus.publish("bart_result", response)
