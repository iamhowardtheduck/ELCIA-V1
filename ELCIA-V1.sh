clear
echo -e "\n\n\n\n\n\n\n"
if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run as \"root\" OR as \"sudo $USER\"; please try again." 1>&2
  exit 1
fi
sudo apt update -y
sudo apt install dialog git -y
#
# BEGIN WELCOME SCREEN & INITIAL UPDATING
#
clear
echo -e "\n\n\n\n\n\n\n"
echo "        Welcome I am ELCIA, your..." 
echo " Elastic & ChatGPT Integration Application"
echo -e "\n\n\n\n\n\n\n"
echo "You can choose to either:"
echo ""
echo "Configre an Elastic Cloud instance with ChatGPT" 
echo ""
echo "Configre an Elastic Cloud instance with ChatGPT to answer like a pirate" 
echo ""
echo "Configre an Elastic Cloud instance with ChatGPT to answer like an angry drunk"
echo ""
echo "Configre an Elastic Cloud instance with ChatGPT to answer like a little kid"
echo ""
echo "Configre an Elastic Cloud instance with ChatGPT to answer like a ganster rapper"
echo ""
echo "Just download the guts, and do the rest yourself"
echo -e "\n\n\n"
echo "But first we must run a few commands to get ready."
echo -e "\n\n\n"
read -n 1 -s -r -p "Press any key to continue"
echo ""
echo "Enjoy! ☺"
clear
clear
#
cmd=(dialog --radiolist "Which would you like to do?" 22 135 16)
options=(1 "Configre an Elastic Cloud instance with ChatGPT" off    # any option can be set to default to "on"
         2 "Configre an Elastic Cloud instance with ChatGPT to answer like a pirate" off
         3 "Configre an Elastic Cloud instance with ChatGPT to answer like an angry drunk" off
         4 "Configre an Elastic Cloud instance with ChatGPT to answer like a little kid" off
	 5 "Configre an Elastic Cloud instance with ChatGPT to answer like a ganster rapper" off
         6 "Just download the guts, and do the rest yourself" off
         7 "Make like a tree, and leave." off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
# Configre an Elastic Cloud instance with ChatGPT
        1)      clear
echo "This is designed to be run on a minimal server install of Ubuntu 22.04 AFTER 'sudo apt update' has been run and the system was rebooted."
echo ""
echo "You will also need a version 8.8+ cluster with an ML node with at least 4GB of RAM, as well as login credentials and your cluster's ES endpoint."
echo ""
echo "So please make sure you have all of this prior to continuing."
echo ""
echo ""
echo ""
read -n 1 -s -r -p "Press any key to continue"
sudo apt install docker.io* python3-pip* curl -y
sudo pip install streamlit
sudo pip install openai
sudo pip install Elasticsearch
clear
echo ""
echo "What is your username?  Typically it is just 'elastic'."
echo ""
read cloud_user
echo ""
echo "What is your password?  If you're using 'elastic' and forgot it, you can reset it from the cloud UI."
echo ""
read cloud_pass
echo ""
echo "What is your Cloud ID? Please copy & paste it directly from the cloud UI with the trailing '=='"
echo ""
read cloud_id
echo ""
echo "Please copy and paste your Elasticsearch endpoint from the cloud UI below WITHOUT the 'https://' portion"
echo ""
echo "Example:  my-cluster-is-awesome.es.us-east4.gcp.elastic-cloud.com"
echo ""
echo ""
read es_client
echo ""
echo ""
echo "Next we'll load the sentence transformers model into your cluster using Docker!"
echo ""
cd /home/$USER && git clone https://github.com/elastic/eland.git && cd eland && sudo docker build -t elastic/eland . && sudo docker run -it --rm --network host elastic/eland eland_import_hub_model --url https://${cloud_user}:${cloud_pass}@${es_client}:9243/ --hub-model-id sentence-transformers/all-distilroberta-v1  --start
echo ""
echo "Next let's create the pipeline so you can use it over and over again!"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_ingest/pipeline/ml-inference-title-vector?pretty" -H 'Content-Type: application/json' -d' {"processors":[{"remove": {"field": "ml.inference.title-vector", "ignore_missing": true}},{"remove": {"field": "title-vector", "ignore_missing": true}},{"inference": {"field_map": {"title": "text_field"}, "model_id": "sentence-transformers__all-distilroberta-v1","target_field": "ml.inference.title-vector","on_failure":[{"append":{"field":"_source._ingest.inference_errors","value":[{"message": "Processor 'inference' in pipeline ml-inference-title-vector failed with message {{ _ingest.on_failure_message }}","pipeline": "ml-inference-title-vector","timestamp":"{{{ _ingest.timestamp }}}"}]}}]}},{"append": {"field":"_source._ingest.processors","value": [{"model_version":"8.8.1","pipeline":"ml-inference-title-vector","processed_timestamp":"{{{ _ingest.timestamp }}}","types":["pytorch","text_embedding"]}]}},{"set":{"copy_from":"ml.inference.title-vector.predicted_value","description": "Copy the predicted_value to title-vector","field": "title-vector","if": "ctx?.ml?.inference != null && ctx.ml.inference['\''title-vector'\''] != null"}}]} '
echo ""
echo "Now let's prepare the index so that when you go to create it in the GUI, you won't have to update the mappings in DevTools!"
echo ""
echo "This will create the 'elcia-script' index template which will be used for all 'search-*' indices"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_index_template/elcia-script?pretty" -H 'Content-Type: application/json' -d '{"index_patterns": ["search-*"],"template":{"settings": {"number_of_shards": 2,"auto_expand_replicas": "0-3","default_pipeline":"ml-inference-title-vector","similarity": {"default": {"type": "BM25"}}},"mappings": {"properties": {"title-vector": {"type": "dense_vector","dims": 768,"index": true,"similarity": "dot_product"},"created_at":{"type":"date","format":"EEE MMM dd HH:mm:ss Z yyyy"}}}}}'
echo ""
echo "Now we'll create the search application"
echo ""
echo "But first two variables need to be passed."
echo ""
echo "What will your index be? Typically it's 'search-something'"
echo ""
read index
echo ""
echo "Next, what will we call your ChatGPT web UI?  Typically it's the name of the website you plan on crawling."
echo ""
echo "So if you plan on crawling 'widgets.com' and want a Widgets GPT UI, just put 'Widgets' and I'll make the necessary changes for you."
echo ""
read engine
echo ""
echo "import os" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import streamlit as st" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import openai" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "from elasticsearch import Elasticsearch" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# This code is part of an Elastic Blog showing how to combine" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch's search relevancy power with" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# OpenAI's GPT's Question Answering power" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# https://www.elastic.co/blog/chatgpt-elasticsearch-openai-meets-private-data" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Code is presented for demo purposes but should not be used in production" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# You may encounter exceptions which are not handled in the code" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Required Environment Variables" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# openai_api - OpenAI API Key" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_id - Elastic Cloud Deployment ID" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_user - Elasticsearch Cluster User" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_pass - Elasticsearch User Password" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "openai.api_key = os.environ['openai_api']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "model = \"gpt-3.5-turbo-0613\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Connect to Elastic Cloud cluster" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def es_connect(cid, user, passwd):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = Elasticsearch(cloud_id=cid, basic_auth=(user, passwd))" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return es" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Search ElasticSearch index and return body and URL of the result" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def search(query_text):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cid = os.environ['cloud_id']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cp = os.environ['cloud_pass']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cu = os.environ['cloud_user']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = es_connect(cid, cu, cp)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch query (BM25) and kNN configuration for hybrid search" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"bool\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"must\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"match\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"title\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"query\": query_text," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"boost\": 1" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                       }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                  }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }]," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"filter\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"exists\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"field\": \"title-vector\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "             }]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    knn = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"field\": \"title-vector\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"k\": 1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"num_candidates\": 20," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"query_vector_builder\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "           \"text_embedding\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_id\": \"sentence-transformers__all-distilroberta-v1\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_text\": query_text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        \"boost\": 24" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    fields = [\"title\", \"body_content\", \"url\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    index = 'search-${index}'" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp = es.search(index=index," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     query=query," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     knn=knn," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     fields=fields," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     size=1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     source=False)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    body = resp['hits']['hits'][0]['fields']['body_content'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    url = resp['hits']['hits'][0]['fields']['url'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return body, url" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def truncate_text(text, max_tokens):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    tokens = text.split()" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if len(tokens) <= max_tokens:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        return text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return ' '.join(tokens[:max_tokens])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate a response from ChatGPT based on the given prompt" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def chat_gpt(prompt, model=\"gpt-3.5-turbo\", max_tokens=1024, max_context_tokens=4000, safety_margin=5):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    # Truncate the prompt content to fit within the model's context length" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    truncated_prompt = truncate_text(prompt, max_context_tokens - max_tokens - safety_margin)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    response = openai.ChatCompletion.create(model=model," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                                                  messages=[{\"role\": \"system\", \"content\": \"You are a helpful assistant.\"}, {\"role\": \"user\", \"content\": truncated_prompt}])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return response[\"choices\"][0][\"message\"][\"content\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "st.title(\"${engine} GPT\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Main chat form" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "with st.form(\"chat_form\"):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = st.text_input(\"You: \")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    submit_button = st.form_submit_button(\"Send\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate and display response on form submission" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "negResponse = \"I'm unable to answer the question based on the information I have my Elastic Data-set.\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "if submit_button:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp, url = search(query)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    prompt = f\"Answer this question: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a pirate: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like an angry drunk: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a little kid: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a gangster rapper: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    answer = chat_gpt(prompt)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if negResponse in answer:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    else:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\n\nDocs: {url}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo ""
echo ""
echo ""
echo "Now let's start the web UI, and all you'll have to do is crawl!"
export cloud_id=${cloud_id}
export cloud_user=${cloud_user}
export cloud_pass=${cloud_pass}
echo ""
echo "What is your Open AI api key?"
echo ""
read openai_api
export openai_api=${openai_api}
streamlit run /home/$USER/eland/chatgpt4all.py
;;
#
# Configre an Elastic Cloud instance with ChatGPT to answer like a pirate
#
2)      clear
echo "This is designed to be run on a minimal server install of Ubuntu 22.04 AFTER 'sudo apt update' has been run and the system was rebooted."
echo ""
echo "You will also need a cluster with an ML node with at least 4GB of RAM, as well as login credentials and your cluster's ES endpoint."
echo ""
echo "So please make sure you have all of this prior to continuing."
echo ""
echo ""
echo ""
read -n 1 -s -r -p "Press any key to continue"
sudo apt install docker.io* python3-pip* curl -y
sudo pip install streamlit
sudo pip install openai
sudo pip install Elasticsearch
clear
echo ""
echo "What is your username?  Typically it is just 'elastic'."
echo ""
read cloud_user
echo ""
echo "What is your password?  If you're using 'elastic' and forgot it, you can reset it from the cloud UI."
echo ""
read cloud_pass
echo ""
echo "What is your Cloud ID? Please copy & paste it directly from the cloud UI with the trailing '=='"
echo ""
read cloud_id
echo ""
echo "Please copy and paste your Elasticsearch endpoint from the cloud UI below WITHOUT the 'https://' portion"
echo ""
echo "Example:  my-cluster-is-awesome.es.us-east4.gcp.elastic-cloud.com"
echo ""
echo ""
read es_client
echo ""
echo ""
echo "Next we'll load the sentence transformers model into your cluster using Docker!"
echo ""
cd /home/$USER && git clone https://github.com/elastic/eland.git && cd eland && sudo docker build -t elastic/eland . && sudo docker run -it --rm --network host elastic/eland eland_import_hub_model --url https://${cloud_user}:${cloud_pass}@${es_client}:9243/ --hub-model-id sentence-transformers/all-distilroberta-v1  --start
echo ""
echo "Next let's create the pipeline so you can use it over and over again!"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_ingest/pipeline/ml-inference-title-vector?pretty" -H 'Content-Type: application/json' -d' {"processors":[{"remove": {"field": "ml.inference.title-vector", "ignore_missing": true}},{"remove": {"field": "title-vector", "ignore_missing": true}},{"inference": {"field_map": {"title": "text_field"}, "model_id": "sentence-transformers__all-distilroberta-v1","target_field": "ml.inference.title-vector","on_failure":[{"append":{"field":"_source._ingest.inference_errors","value":[{"message": "Processor 'inference' in pipeline ml-inference-title-vector failed with message {{ _ingest.on_failure_message }}","pipeline": "ml-inference-title-vector","timestamp":"{{{ _ingest.timestamp }}}"}]}}]}},{"append": {"field":"_source._ingest.processors","value": [{"model_version":"8.8.1","pipeline":"ml-inference-title-vector","processed_timestamp":"{{{ _ingest.timestamp }}}","types":["pytorch","text_embedding"]}]}},{"set":{"copy_from":"ml.inference.title-vector.predicted_value","description": "Copy the predicted_value to title-vector","field": "title-vector","if": "ctx?.ml?.inference != null && ctx.ml.inference['\''title-vector'\''] != null"}}]} '
echo ""
echo "Now let's prepare the index so that when you go to create it in the GUI, you won't have to update the mappings in DevTools!"
echo ""
echo "This will create the 'elcia-script' index template which will be used for all 'search-*' indices"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_index_template/elcia-script?pretty" -H 'Content-Type: application/json' -d '{"index_patterns": ["search-*"],"template":{"settings": {"number_of_shards": 2,"auto_expand_replicas": "0-3","default_pipeline":"ml-inference-title-vector","similarity": {"default": {"type": "BM25"}}},"mappings": {"properties": {"title-vector": {"type": "dense_vector","dims": 768,"index": true,"similarity": "dot_product"},"created_at":{"type":"date","format":"EEE MMM dd HH:mm:ss Z yyyy"}}}}}'
echo ""
echo "Now we'll create the search application"
echo ""
echo "But first two variables need to be passed."
echo ""
echo "What will your index be? Typically it's 'search-something'"
echo ""
read index
echo ""
echo "Next, what will we call your ChatGPT web UI?  Typically it's the name of the website you plan on crawling."
echo ""
echo "So if you plan on crawling 'widgets.com' and want a Widgets GPT UI, just put 'Widgets' and I'll make the necessary changes for you."
echo ""
read engine
echo ""
echo "import os" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import streamlit as st" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import openai" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "from elasticsearch import Elasticsearch" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# This code is part of an Elastic Blog showing how to combine" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch's search relevancy power with" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# OpenAI's GPT's Question Answering power" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# https://www.elastic.co/blog/chatgpt-elasticsearch-openai-meets-private-data" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Code is presented for demo purposes but should not be used in production" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# You may encounter exceptions which are not handled in the code" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Required Environment Variables" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# openai_api - OpenAI API Key" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_id - Elastic Cloud Deployment ID" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_user - Elasticsearch Cluster User" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_pass - Elasticsearch User Password" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "openai.api_key = os.environ['openai_api']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "model = \"gpt-3.5-turbo-0613\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Connect to Elastic Cloud cluster" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def es_connect(cid, user, passwd):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = Elasticsearch(cloud_id=cid, basic_auth=(user, passwd))" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return es" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Search ElasticSearch index and return body and URL of the result" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def search(query_text):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cid = os.environ['cloud_id']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cp = os.environ['cloud_pass']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cu = os.environ['cloud_user']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = es_connect(cid, cu, cp)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch query (BM25) and kNN configuration for hybrid search" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"bool\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"must\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"match\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"title\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"query\": query_text," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"boost\": 1" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                       }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                  }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }]," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"filter\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"exists\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"field\": \"title-vector\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "             }]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    knn = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"field\": \"title-vector\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"k\": 1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"num_candidates\": 20," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"query_vector_builder\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "           \"text_embedding\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_id\": \"sentence-transformers__all-distilroberta-v1\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_text\": query_text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        \"boost\": 24" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    fields = [\"title\", \"body_content\", \"url\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    index = 'search-${index}'" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp = es.search(index=index," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     query=query," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     knn=knn," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     fields=fields," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     size=1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     source=False)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    body = resp['hits']['hits'][0]['fields']['body_content'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    url = resp['hits']['hits'][0]['fields']['url'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return body, url" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def truncate_text(text, max_tokens):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    tokens = text.split()" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if len(tokens) <= max_tokens:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        return text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return ' '.join(tokens[:max_tokens])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate a response from ChatGPT based on the given prompt" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def chat_gpt(prompt, model=\"gpt-3.5-turbo\", max_tokens=1024, max_context_tokens=4000, safety_margin=5):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    # Truncate the prompt content to fit within the model's context length" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    truncated_prompt = truncate_text(prompt, max_context_tokens - max_tokens - safety_margin)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    response = openai.ChatCompletion.create(model=model," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                                                  messages=[{\"role\": \"system\", \"content\": \"You are a helpful assistant.\"}, {\"role\": \"user\", \"content\": truncated_prompt}])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return response[\"choices\"][0][\"message\"][\"content\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "st.title(\"${engine} GPT\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Main chat form" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "with st.form(\"chat_form\"):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = st.text_input(\"You: \")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    submit_button = st.form_submit_button(\"Send\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate and display response on form submission" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "negResponse = \"I'm unable to answer the question based on the information I have my Elastic Data-set.\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "if submit_button:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp, url = search(query)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    prompt = f\"Answer this question like a pirate: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like an angry drunk: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a little kid: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a gangster rapper: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    answer = chat_gpt(prompt)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if negResponse in answer:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    else:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\n\nDocs: {url}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo ""
echo ""
echo ""
echo "Now let's start the web UI, and all you'll have to do is crawl!"
export cloud_id=${cloud_id}
export cloud_user=${cloud_user}
export cloud_pass=${cloud_pass}
echo ""
echo "What is your Open AI api key?"
echo ""
read openai_api
export openai_api=${openai_api}
streamlit run /home/$USER/eland/chatgpt4all.py
;;
#
# Configure an Elastic Cloud instance with ChatGPT to answer like an angry drunk
#
3)      clear
echo "This is designed to be run on a minimal server install of Ubuntu 22.04 AFTER 'sudo apt update' has been run and the system was rebooted."
echo ""
echo "You will also need a cluster with an ML node with at least 4GB of RAM, as well as login credentials and your cluster's ES endpoint."
echo ""
echo "So please make sure you have all of this prior to continuing."
echo ""
echo ""
echo ""
read -n 1 -s -r -p "Press any key to continue"
sudo apt install docker.io* python3-pip* curl -y
sudo pip install streamlit
sudo pip install openai
sudo pip install Elasticsearch
clear
echo ""
echo "What is your username?  Typically it is just 'elastic'."
echo ""
read cloud_user
echo ""
echo "What is your password?  If you're using 'elastic' and forgot it, you can reset it from the cloud UI."
echo ""
read cloud_pass
echo ""
echo "What is your Cloud ID? Please copy & paste it directly from the cloud UI with the trailing '=='"
echo ""
read cloud_id
echo ""
echo "Please copy and paste your Elasticsearch endpoint from the cloud UI below WITHOUT the 'https://' portion"
echo ""
echo "Example:  my-cluster-is-awesome.es.us-east4.gcp.elastic-cloud.com"
echo ""
echo ""
read es_client
echo ""
echo ""
echo "Next we'll load the sentence transformers model into your cluster using Docker!"
echo ""
cd /home/$USER && git clone https://github.com/elastic/eland.git && cd eland && sudo docker build -t elastic/eland . && sudo docker run -it --rm --network host elastic/eland eland_import_hub_model --url https://${cloud_user}:${cloud_pass}@${es_client}:9243/ --hub-model-id sentence-transformers/all-distilroberta-v1  --start
echo ""
echo "Next let's create the pipeline so you can use it over and over again!"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_ingest/pipeline/ml-inference-title-vector?pretty" -H 'Content-Type: application/json' -d' {"processors":[{"remove": {"field": "ml.inference.title-vector", "ignore_missing": true}},{"remove": {"field": "title-vector", "ignore_missing": true}},{"inference": {"field_map": {"title": "text_field"}, "model_id": "sentence-transformers__all-distilroberta-v1","target_field": "ml.inference.title-vector","on_failure":[{"append":{"field":"_source._ingest.inference_errors","value":[{"message": "Processor 'inference' in pipeline ml-inference-title-vector failed with message {{ _ingest.on_failure_message }}","pipeline": "ml-inference-title-vector","timestamp":"{{{ _ingest.timestamp }}}"}]}}]}},{"append": {"field":"_source._ingest.processors","value": [{"model_version":"8.8.1","pipeline":"ml-inference-title-vector","processed_timestamp":"{{{ _ingest.timestamp }}}","types":["pytorch","text_embedding"]}]}},{"set":{"copy_from":"ml.inference.title-vector.predicted_value","description": "Copy the predicted_value to title-vector","field": "title-vector","if": "ctx?.ml?.inference != null && ctx.ml.inference['\''title-vector'\''] != null"}}]} '
echo ""
echo "Now let's prepare the index so that when you go to create it in the GUI, you won't have to update the mappings in DevTools!"
echo ""
echo "This will create the 'elcia-script' index template which will be used for all 'search-*' indices"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_index_template/elcia-script?pretty" -H 'Content-Type: application/json' -d '{"index_patterns": ["search-*"],"template":{"settings": {"number_of_shards": 2,"auto_expand_replicas": "0-3","default_pipeline":"ml-inference-title-vector","similarity": {"default": {"type": "BM25"}}},"mappings": {"properties": {"title-vector": {"type": "dense_vector","dims": 768,"index": true,"similarity": "dot_product"},"created_at":{"type":"date","format":"EEE MMM dd HH:mm:ss Z yyyy"}}}}}'
echo ""
echo "Now we'll create the search application"
echo ""
echo "But first two variables need to be passed."
echo ""
echo "What will your index be? Typically it's 'search-something'"
echo ""
read index
echo ""
echo "Next, what will we call your ChatGPT web UI?  Typically it's the name of the website you plan on crawling."
echo ""
echo "So if you plan on crawling 'widgets.com' and want a Widgets GPT UI, just put 'Widgets' and I'll make the necessary changes for you."
echo ""
read engine
echo ""
echo "import os" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import streamlit as st" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import openai" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "from elasticsearch import Elasticsearch" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# This code is part of an Elastic Blog showing how to combine" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch's search relevancy power with" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# OpenAI's GPT's Question Answering power" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# https://www.elastic.co/blog/chatgpt-elasticsearch-openai-meets-private-data" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Code is presented for demo purposes but should not be used in production" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# You may encounter exceptions which are not handled in the code" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Required Environment Variables" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# openai_api - OpenAI API Key" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_id - Elastic Cloud Deployment ID" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_user - Elasticsearch Cluster User" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_pass - Elasticsearch User Password" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "openai.api_key = os.environ['openai_api']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "model = \"gpt-3.5-turbo-0613\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Connect to Elastic Cloud cluster" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def es_connect(cid, user, passwd):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = Elasticsearch(cloud_id=cid, basic_auth=(user, passwd))" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return es" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Search ElasticSearch index and return body and URL of the result" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def search(query_text):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cid = os.environ['cloud_id']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cp = os.environ['cloud_pass']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cu = os.environ['cloud_user']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = es_connect(cid, cu, cp)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch query (BM25) and kNN configuration for hybrid search" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"bool\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"must\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"match\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"title\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"query\": query_text," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"boost\": 1" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                       }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                  }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }]," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"filter\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"exists\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"field\": \"title-vector\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "             }]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    knn = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"field\": \"title-vector\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"k\": 1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"num_candidates\": 20," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"query_vector_builder\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "           \"text_embedding\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_id\": \"sentence-transformers__all-distilroberta-v1\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_text\": query_text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        \"boost\": 24" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    fields = [\"title\", \"body_content\", \"url\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    index = 'search-${index}'" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp = es.search(index=index," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     query=query," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     knn=knn," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     fields=fields," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     size=1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     source=False)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    body = resp['hits']['hits'][0]['fields']['body_content'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    url = resp['hits']['hits'][0]['fields']['url'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return body, url" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def truncate_text(text, max_tokens):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    tokens = text.split()" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if len(tokens) <= max_tokens:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        return text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return ' '.join(tokens[:max_tokens])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate a response from ChatGPT based on the given prompt" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def chat_gpt(prompt, model=\"gpt-3.5-turbo\", max_tokens=1024, max_context_tokens=4000, safety_margin=5):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    # Truncate the prompt content to fit within the model's context length" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    truncated_prompt = truncate_text(prompt, max_context_tokens - max_tokens - safety_margin)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    response = openai.ChatCompletion.create(model=model," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                                                  messages=[{\"role\": \"system\", \"content\": \"You are a helpful assistant.\"}, {\"role\": \"user\", \"content\": truncated_prompt}])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return response[\"choices\"][0][\"message\"][\"content\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "st.title(\"${engine} GPT\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Main chat form" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "with st.form(\"chat_form\"):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = st.text_input(\"You: \")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    submit_button = st.form_submit_button(\"Send\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate and display response on form submission" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "negResponse = \"I'm unable to answer the question based on the information I have my Elastic Data-set.\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "if submit_button:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp, url = search(query)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a pirate: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    prompt = f\"Answer this question like an angry drunk: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a little kid: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a gangster rapper: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    answer = chat_gpt(prompt)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if negResponse in answer:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    else:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\n\nDocs: {url}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo ""
echo ""
echo ""
echo "Now let's start the web UI, and all you'll have to do is crawl!"
export cloud_id=${cloud_id}
export cloud_user=${cloud_user}
export cloud_pass=${cloud_pass}
echo ""
echo "What is your Open AI api key?"
echo ""
read openai_api
export openai_api=${openai_api}
streamlit run /home/$USER/eland/chatgpt4all.py
;;
#
# Configre an Elastic Cloud instance with ChatGPT to answer like a little kid
#
4)      clear
echo "This is designed to be run on a minimal server install of Ubuntu 22.04 AFTER 'sudo apt update' has been run and the system was rebooted."
echo ""
echo "You will also need a cluster with an ML node with at least 4GB of RAM, as well as login credentials and your cluster's ES endpoint."
echo ""
echo "So please make sure you have all of this prior to continuing."
echo ""
echo ""
echo ""
read -n 1 -s -r -p "Press any key to continue"
sudo apt install docker.io* python3-pip* curl -y
sudo pip install streamlit
sudo pip install openai
sudo pip install Elasticsearch
clear
echo ""
echo "What is your username?  Typically it is just 'elastic'."
echo ""
read cloud_user
echo ""
echo "What is your password?  If you're using 'elastic' and forgot it, you can reset it from the cloud UI."
echo ""
read cloud_pass
echo ""
echo "What is your Cloud ID? Please copy & paste it directly from the cloud UI with the trailing '=='"
echo ""
read cloud_id
echo ""
echo "Please copy and paste your Elasticsearch endpoint from the cloud UI below WITHOUT the 'https://' portion"
echo ""
echo "Example:  my-cluster-is-awesome.es.us-east4.gcp.elastic-cloud.com"
echo ""
echo ""
read es_client
echo ""
echo ""
echo "Next we'll load the sentence transformers model into your cluster using Docker!"
echo ""
cd /home/$USER && git clone https://github.com/elastic/eland.git && cd eland && sudo docker build -t elastic/eland . && sudo docker run -it --rm --network host elastic/eland eland_import_hub_model --url https://${cloud_user}:${cloud_pass}@${es_client}:9243/ --hub-model-id sentence-transformers/all-distilroberta-v1  --start
echo ""
echo "Next let's create the pipeline so you can use it over and over again!"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_ingest/pipeline/ml-inference-title-vector?pretty" -H 'Content-Type: application/json' -d' {"processors":[{"remove": {"field": "ml.inference.title-vector", "ignore_missing": true}},{"remove": {"field": "title-vector", "ignore_missing": true}},{"inference": {"field_map": {"title": "text_field"}, "model_id": "sentence-transformers__all-distilroberta-v1","target_field": "ml.inference.title-vector","on_failure":[{"append":{"field":"_source._ingest.inference_errors","value":[{"message": "Processor 'inference' in pipeline ml-inference-title-vector failed with message {{ _ingest.on_failure_message }}","pipeline": "ml-inference-title-vector","timestamp":"{{{ _ingest.timestamp }}}"}]}}]}},{"append": {"field":"_source._ingest.processors","value": [{"model_version":"8.8.1","pipeline":"ml-inference-title-vector","processed_timestamp":"{{{ _ingest.timestamp }}}","types":["pytorch","text_embedding"]}]}},{"set":{"copy_from":"ml.inference.title-vector.predicted_value","description": "Copy the predicted_value to title-vector","field": "title-vector","if": "ctx?.ml?.inference != null && ctx.ml.inference['\''title-vector'\''] != null"}}]} '
echo ""
echo "Now let's prepare the index so that when you go to create it in the GUI, you won't have to update the mappings in DevTools!"
echo ""
echo "This will create the 'elcia-script' index template which will be used for all 'search-*' indices"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_index_template/elcia-script?pretty" -H 'Content-Type: application/json' -d '{"index_patterns": ["search-*"],"template":{"settings": {"number_of_shards": 2,"auto_expand_replicas": "0-3","default_pipeline":"ml-inference-title-vector","similarity": {"default": {"type": "BM25"}}},"mappings": {"properties": {"title-vector": {"type": "dense_vector","dims": 768,"index": true,"similarity": "dot_product"},"created_at":{"type":"date","format":"EEE MMM dd HH:mm:ss Z yyyy"}}}}}'
echo ""
echo "Now we'll create the search application"
echo ""
echo "But first two variables need to be passed."
echo ""
echo "What will your index be? Typically it's 'search-something'"
echo ""
read index
echo ""
echo "Next, what will we call your ChatGPT web UI?  Typically it's the name of the website you plan on crawling."
echo ""
echo "So if you plan on crawling 'widgets.com' and want a Widgets GPT UI, just put 'Widgets' and I'll make the necessary changes for you."
echo ""
read engine
echo ""
echo "import os" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import streamlit as st" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import openai" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "from elasticsearch import Elasticsearch" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# This code is part of an Elastic Blog showing how to combine" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch's search relevancy power with" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# OpenAI's GPT's Question Answering power" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# https://www.elastic.co/blog/chatgpt-elasticsearch-openai-meets-private-data" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Code is presented for demo purposes but should not be used in production" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# You may encounter exceptions which are not handled in the code" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Required Environment Variables" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# openai_api - OpenAI API Key" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_id - Elastic Cloud Deployment ID" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_user - Elasticsearch Cluster User" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_pass - Elasticsearch User Password" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "openai.api_key = os.environ['openai_api']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "model = \"gpt-3.5-turbo-0613\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Connect to Elastic Cloud cluster" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def es_connect(cid, user, passwd):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = Elasticsearch(cloud_id=cid, basic_auth=(user, passwd))" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return es" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Search ElasticSearch index and return body and URL of the result" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def search(query_text):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cid = os.environ['cloud_id']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cp = os.environ['cloud_pass']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cu = os.environ['cloud_user']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = es_connect(cid, cu, cp)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch query (BM25) and kNN configuration for hybrid search" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"bool\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"must\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"match\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"title\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"query\": query_text," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"boost\": 1" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                       }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                  }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }]," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"filter\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"exists\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"field\": \"title-vector\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "             }]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    knn = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"field\": \"title-vector\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"k\": 1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"num_candidates\": 20," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"query_vector_builder\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "           \"text_embedding\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_id\": \"sentence-transformers__all-distilroberta-v1\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_text\": query_text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        \"boost\": 24" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    fields = [\"title\", \"body_content\", \"url\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    index = 'search-${index}'" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp = es.search(index=index," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     query=query," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     knn=knn," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     fields=fields," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     size=1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     source=False)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    body = resp['hits']['hits'][0]['fields']['body_content'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    url = resp['hits']['hits'][0]['fields']['url'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return body, url" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def truncate_text(text, max_tokens):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    tokens = text.split()" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if len(tokens) <= max_tokens:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        return text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return ' '.join(tokens[:max_tokens])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate a response from ChatGPT based on the given prompt" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def chat_gpt(prompt, model=\"gpt-3.5-turbo\", max_tokens=1024, max_context_tokens=4000, safety_margin=5):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    # Truncate the prompt content to fit within the model's context length" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    truncated_prompt = truncate_text(prompt, max_context_tokens - max_tokens - safety_margin)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    response = openai.ChatCompletion.create(model=model," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                                                  messages=[{\"role\": \"system\", \"content\": \"You are a helpful assistant.\"}, {\"role\": \"user\", \"content\": truncated_prompt}])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return response[\"choices\"][0][\"message\"][\"content\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "st.title(\"${engine} GPT\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Main chat form" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "with st.form(\"chat_form\"):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = st.text_input(\"You: \")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    submit_button = st.form_submit_button(\"Send\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate and display response on form submission" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "negResponse = \"I'm unable to answer the question based on the information I have my Elastic Data-set.\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "if submit_button:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp, url = search(query)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a pirate: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like an angry drunk: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    prompt = f\"Answer this question like a little kid: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a gangster rapper: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    answer = chat_gpt(prompt)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if negResponse in answer:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    else:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\n\nDocs: {url}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo ""
echo ""
echo ""
echo "Now let's start the web UI, and all you'll have to do is crawl!"
export cloud_id=${cloud_id}
export cloud_user=${cloud_user}
export cloud_pass=${cloud_pass}
echo ""
echo "What is your Open AI api key?"
echo ""
read openai_api
export openai_api=${openai_api}
streamlit run /home/$USER/eland/chatgpt4all.py
;;
#
# Configre an Elastic Cloud instance with ChatGPT to answer like a gangster rapper
#
5)      clear
echo "This is designed to be run on a minimal server install of Ubuntu 22.04 AFTER 'sudo apt update' has been run and the system was rebooted."
echo ""
echo "You will also need a cluster with an ML node with at least 4GB of RAM, as well as login credentials and your cluster's ES endpoint."
echo ""
echo "So please make sure you have all of this prior to continuing."
echo ""
echo ""
echo ""
read -n 1 -s -r -p "Press any key to continue"
sudo apt install docker.io* python3-pip* curl -y
sudo pip install streamlit
sudo pip install openai
sudo pip install Elasticsearch
clear
echo ""
echo "What is your username?  Typically it is just 'elastic'."
echo ""
read cloud_user
echo ""
echo "What is your password?  If you're using 'elastic' and forgot it, you can reset it from the cloud UI."
echo ""
read cloud_pass
echo ""
echo "What is your Cloud ID? Please copy & paste it directly from the cloud UI with the trailing '=='"
echo ""
read cloud_id
echo ""
echo "Please copy and paste your Elasticsearch endpoint from the cloud UI below WITHOUT the 'https://' portion"
echo ""
echo "Example:  my-cluster-is-awesome.es.us-east4.gcp.elastic-cloud.com"
echo ""
echo ""
read es_client
echo ""
echo ""
echo "Next we'll load the sentence transformers model into your cluster using Docker!"
echo ""
cd /home/$USER && git clone https://github.com/elastic/eland.git && cd eland && sudo docker build -t elastic/eland . && sudo docker run -it --rm --network host elastic/eland eland_import_hub_model --url https://${cloud_user}:${cloud_pass}@${es_client}:9243/ --hub-model-id sentence-transformers/all-distilroberta-v1  --start
echo ""
echo "Next let's create the pipeline so you can use it over and over again!"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_ingest/pipeline/ml-inference-title-vector?pretty" -H 'Content-Type: application/json' -d' {"processors":[{"remove": {"field": "ml.inference.title-vector", "ignore_missing": true}},{"remove": {"field": "title-vector", "ignore_missing": true}},{"inference": {"field_map": {"title": "text_field"}, "model_id": "sentence-transformers__all-distilroberta-v1","target_field": "ml.inference.title-vector","on_failure":[{"append":{"field":"_source._ingest.inference_errors","value":[{"message": "Processor 'inference' in pipeline ml-inference-title-vector failed with message {{ _ingest.on_failure_message }}","pipeline": "ml-inference-title-vector","timestamp":"{{{ _ingest.timestamp }}}"}]}}]}},{"append": {"field":"_source._ingest.processors","value": [{"model_version":"8.8.1","pipeline":"ml-inference-title-vector","processed_timestamp":"{{{ _ingest.timestamp }}}","types":["pytorch","text_embedding"]}]}},{"set":{"copy_from":"ml.inference.title-vector.predicted_value","description": "Copy the predicted_value to title-vector","field": "title-vector","if": "ctx?.ml?.inference != null && ctx.ml.inference['\''title-vector'\''] != null"}}]} '
echo ""
echo "Now let's prepare the index so that when you go to create it in the GUI, you won't have to update the mappings in DevTools!"
echo ""
echo "This will create the 'elcia-script' index template which will be used for all 'search-*' indices"
echo ""
curl -X PUT "https://${cloud_user}:${cloud_pass}@${es_client}:9243/_index_template/elcia-script?pretty" -H 'Content-Type: application/json' -d '{"index_patterns": ["search-*"],"template":{"settings": {"number_of_shards": 2,"auto_expand_replicas": "0-3","default_pipeline":"ml-inference-title-vector","similarity": {"default": {"type": "BM25"}}},"mappings": {"properties": {"title-vector": {"type": "dense_vector","dims": 768,"index": true,"similarity": "dot_product"},"created_at":{"type":"date","format":"EEE MMM dd HH:mm:ss Z yyyy"}}}}}'
echo ""
echo "Now we'll create the search application"
echo ""
echo "But first two variables need to be passed."
echo ""
echo "What will your index be? Typically it's 'search-something'"
echo ""
read index
echo ""
echo "Next, what will we call your ChatGPT web UI?  Typically it's the name of the website you plan on crawling."
echo ""
echo "So if you plan on crawling 'widgets.com' and want a Widgets GPT UI, just put 'Widgets' and I'll make the necessary changes for you."
echo ""
read engine
echo ""
echo "import os" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import streamlit as st" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "import openai" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "from elasticsearch import Elasticsearch" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# This code is part of an Elastic Blog showing how to combine" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch's search relevancy power with" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# OpenAI's GPT's Question Answering power" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# https://www.elastic.co/blog/chatgpt-elasticsearch-openai-meets-private-data" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Code is presented for demo purposes but should not be used in production" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# You may encounter exceptions which are not handled in the code" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Required Environment Variables" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# openai_api - OpenAI API Key" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_id - Elastic Cloud Deployment ID" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_user - Elasticsearch Cluster User" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# cloud_pass - Elasticsearch User Password" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "openai.api_key = os.environ['openai_api']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "model = \"gpt-3.5-turbo-0613\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Connect to Elastic Cloud cluster" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def es_connect(cid, user, passwd):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = Elasticsearch(cloud_id=cid, basic_auth=(user, passwd))" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return es" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Search ElasticSearch index and return body and URL of the result" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def search(query_text):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cid = os.environ['cloud_id']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cp = os.environ['cloud_pass']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    cu = os.environ['cloud_user']" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    es = es_connect(cid, cu, cp)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Elasticsearch query (BM25) and kNN configuration for hybrid search" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"bool\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"must\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"match\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"title\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"query\": query_text," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                           \"boost\": 1" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                       }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                  }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }]," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            \"filter\": [{" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"exists\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     \"field\": \"title-vector\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "             }]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    knn = {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"field\": \"title-vector\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"k\": 1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"num_candidates\": 20," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "       \"query_vector_builder\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "           \"text_embedding\": {" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_id\": \"sentence-transformers__all-distilroberta-v1\"," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                \"model_text\": query_text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "            }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        }," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        \"boost\": 24" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    }" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    fields = [\"title\", \"body_content\", \"url\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    index = 'search-${index}'" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp = es.search(index=index," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     query=query," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     knn=knn," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     fields=fields," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     size=1," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                     source=False)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    body = resp['hits']['hits'][0]['fields']['body_content'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    url = resp['hits']['hits'][0]['fields']['url'][0]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return body, url" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def truncate_text(text, max_tokens):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    tokens = text.split()" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if len(tokens) <= max_tokens:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        return text" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return ' '.join(tokens[:max_tokens])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate a response from ChatGPT based on the given prompt" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "def chat_gpt(prompt, model=\"gpt-3.5-turbo\", max_tokens=1024, max_context_tokens=4000, safety_margin=5):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    # Truncate the prompt content to fit within the model's context length" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    truncated_prompt = truncate_text(prompt, max_context_tokens - max_tokens - safety_margin)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    response = openai.ChatCompletion.create(model=model," | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "                                                  messages=[{\"role\": \"system\", \"content\": \"You are a helpful assistant.\"}, {\"role\": \"user\", \"content\": truncated_prompt}])" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    return response[\"choices\"][0][\"message\"][\"content\"]" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "st.title(\"${engine} GPT\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Main chat form" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "with st.form(\"chat_form\"):" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    query = st.text_input(\"You: \")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    submit_button = st.form_submit_button(\"Send\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "# Generate and display response on form submission" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "negResponse = \"I'm unable to answer the question based on the information I have my Elastic Data-set.\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "if submit_button:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    resp, url = search(query)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a pirate: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like an angry drunk: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
#echo "    prompt = f\"Answer this question like a little kid: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    prompt = f\"Answer this question like a gangster rapper: {query}\nUsing only the information from this Elastic Doc: {resp}\nIf the answer is not contained in the supplied doc reply '{negResponse}' and nothing else\"" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    answer = chat_gpt(prompt)" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    if negResponse in answer:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "    else:" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo "        st.write(f\"ChatGPT: {answer.strip()}\n\nDocs: {url}\")" | sudo tee -a /home/$USER/eland/chatgpt4all.py
echo ""
echo ""
echo ""
echo "Now let's start the web UI, and all you'll have to do is crawl!"
export cloud_id=${cloud_id}
export cloud_user=${cloud_user}
export cloud_pass=${cloud_pass}
echo ""
echo "What is your Open AI api key?"
echo ""
read openai_api
export openai_api=${openai_api}
streamlit run /home/$USER/eland/chatgpt4all.py
;;
#
# Just download the guts, and do the rest yourself
#
6)      clear
sudo apt install docker.io* python3-pip* curl -y
sudo pip install streamlit
sudo pip install openai
sudo pip install Elasticsearch
cd /home/$USER && git clone https://github.com/elastic/eland.git && cd eland && sudo docker build -t elastic/eland .
curl -o /home/$USER/eland/chatgpt4all.py https://raw.githubusercontent.com/jeffvestal/ElasticDocs_GPT/main/elasticdocs_gpt.py
clear
echo ""
echo ""
echo "To start the Eland Client and load the sentence-transformers model needed for ChatGPT integration, you will need to pass this command with your variables..."
echo ""
echo "sudo docker run -it --rm --network host elastic/eland eland_import_hub_model --url https://<cloud_user>:<cloud_pass>@<es_client>:<es_port>/ --hub-model-id sentence-transformers/all-distilroberta-v1  --start"
echo ""
echo ""
echo ""
echo "To start the Eland Client and load the named-entity-recognition model needed for PII redaction, you will need to pass this command with your variables..."
echo ""
echo "sudo docker run -it --rm --network host elastic/eland eland_import_hub_model --url https://<cloud_user>:<cloud_pass>@<es_client>:<es_port>/ --hub-model-id dslim/bert-base-NER --task-type ner --start"
echo ""
echo ""
echo ""
echo "Your ChatGPT integration app may be found here: /home/$USER/eland/chatgpt4all.py"
echo ""
echo ""
echo "Make sure to update line 69 (the index where you want to point to), line 100 (the title of the page), line 108 the negative response, and optionally line 111 to a persona."
echo ""
echo ""
echo "You will need to export your cloud_user, cloud_pass, cloud_id, and openai_api variables for use with streamlit."
echo ""
echo "This may be accomplished like so:  export cloud_user=elastic"
echo ""
echo "Now you can run streamlit like so:   streamlit run /home/$USER/eland/chatgpt4all.py"
echo ""
echo ""
echo ""
read -n 1 -s -r -p "Press any key to continue"
;;
7)     clear
exit
esac
done
