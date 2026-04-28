# Проектирование GraphQL API

[Схема GraphQL API](./schema.graphql)

Запуск тестового сервера GraphQL
```bash
cd <project_dir>

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

strawberry dev task5.scheme
```

Проверка эквивалентности основных операций:

- **/clients/{id} GET**: 
Query:
```graphql
{
  client (id: "Kostik") {
    id
    name
    age
  }
}
```

Expected response:

```graphql
{
  "data": {
    "client": {
      "id": "Kostik",
      "name": "Anatoliy",
      "age": 12
    }
  }
}
```

- **/clients/{id}/documents GET**

Query:
```graphql
{
  documents (clientId: "13") {
    id
    type
    number
    issueDate
    expiryDate
  }
}
```

Expected response:

```graphql
{
  "data": {
    "documents": [
      {
        "id": "2",
        "type": "passport",
        "number": "654321",
        "issueDate": "11.09.2015",
        "expiryDate": "11.09.2027"
      },
      {
        "id": "3",
        "type": "driver license",
        "number": "QWWE32",
        "issueDate": "01.12.2018",
        "expiryDate": "01.12.2028"
      }
    ]
  }
}
```

- **/clients/{id}/relatives GET**

Query:
```graphql
{
  relatives (clientId: "Mozart") {
    id
		relationType
    name
    age
  }
}
```

Expected response:

```graphql
{
  "data": {
    "relatives": [
      {
        "id": "Mozart's Father",
        "relationType": "father",
        "name": "Leopold",
        "age": 215
      },
      {
        "id": "Mozart's Mother",
        "relationType": "mother",
        "name": "Anna Maria",
        "age": 212
      }
    ]
  }
}
```
