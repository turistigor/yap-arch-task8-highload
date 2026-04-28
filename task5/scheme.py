import typing
import strawberry


@strawberry.type
class Document:
    id: str
    type: str
    number: str
    issueDate: str
    expiryDate: str


@strawberry.type
class Relative:
    id: str
    relation_type: str
    name: str
    age: int


@strawberry.type
class Client:
    id: str
    name: str
    age: int
    documents: typing.Tuple[Document]
    relatives: typing.Tuple[Relative]


clients = {
    '13': Client(
        id='13',
        name='Olivia',
        age=28,
        documents=(
            Document(id='2', type='passport', number='654321', issueDate='11.09.2015', expiryDate='11.09.2027'),
            Document(id='3', type='driver license', number='QWWE32', issueDate='01.12.2018', expiryDate='01.12.2028'),
        ),
        relatives = (
            Relative(id='Kostik', relation_type='son', name='Anatoliy', age=12),
        ),
    ),
    'Mozart': Client(
        id='Mozart',
        name='Amadeus',
        age=192,
        documents=(
            Document(id='1', type='diploma', number='2', issueDate='11.03.1770', expiryDate='endless'),
        ),
        relatives = (
            Relative(id='Mozart\'s Father', relation_type='father', name='Leopold', age=215),
            Relative(id='Mozart\'s Mother', relation_type='mother', name='Anna Maria', age=212),
        ),
    ),
    'Kostik': Client(
        id='Kostik',
        name='Anatoliy',
        age=12,
        documents=(
            Document(id='4', type='birth certificate', number='861273821', issueDate='28.04.2026', expiryDate='Who knows...;-)'),
            Document(id='5', type='school diary', number='123', issueDate='01.09.2025', expiryDate='31.05.2026'),
        ),
        relatives = (
            Relative(id='13', relation_type='mother', name='Olivia', age=28),
        ),
    ),
}


def get_client(id: str) -> Client:
    return clients[id]


def get_documents(client_id: str) -> typing.Iterable[Document]:
    return get_client(client_id).documents


def get_relatives(client_id: str) -> typing.Iterable[Relative]:
    return get_client(client_id).relatives


@strawberry.type
class Query:
    client: Client =  strawberry.field(resolver=get_client)
    documents: typing.Tuple[Document] = strawberry.field(resolver=get_documents)
    relatives: typing.Tuple[Relative] = strawberry.field(resolver=get_relatives)


schema = strawberry.Schema(query=Query)
