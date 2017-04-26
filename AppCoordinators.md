# Application Coordinators

## Что это?

Это подход к организации взаимодействия между представлением (`View`) и моделью (`Model`).

## Задача

Допустим есть сценарий в рамках которого пользователь редактирует сущности в некотором списке.
При этом для редактирования некоторых свойств сущностей предусмотрены отдельные представления
(`UIViewController`).
Т.о. имеем  `ListViewController`, `DetailsViewController` и `EditorViewController`.

Доп. требования:

* каждый раз, когда `EditorViewController` изменяет одно из свойств сущности `ListViewController` и 
`DetailsViewController` должны отразить это изменение;
* у пользователя должна быть возможность вернуть с экрана редактирования определнного свойства
сразу к списку;

## Решение в лоб

Поток управления и данных:

* `ListViewController` <-> `DetailsViewController` <-> `EditorViewController`
* `ListViewController` <- `EditorViewController`

```swift

class ListViewController: UIViewController, DetailsViewControllerDelegate {
	var data: [Entity] = []

	func viewDidLoad() {
		super.viewDidLoad()

		DataService.shared.loadData { newData in
			self.data = newData
			self.update()
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let details = segue.destination as! DetailsViewController
        details.entity = data[selectedIndex]
    }

	func detailsViewController(_ sender: EditorViewController, didChangeEntity: Entity) {
		updateList()
    }    
}

class DetailsViewController: UIViewController, EditorViewControllerDelegate {
	var data: Entity!
	weak var delegate: DetailsViewControllerDelegate?

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editor = segue.destination as! EditorViewController
        editor.value = valueOfSelectedProperty(data)
        editor.delegate = self
    }

    func editorViewController(_ sender: EditorViewController, didChangeValue newValue: Value) {
    	updateSelectedProperty(data, value: newValue)
    	delegate?.detailsViewController(self, didChangeEntity: data)
    }

    func homeTapped(_ sender: AnyObject?) {
    	navigationController?.popToRootViewController(animated: true)
    }
}

```

Что имеем:

* данные и логика их обработки размазаны по всей цепочке представлений;
* данные гоняются по всей цепочке туда-сюда;
* представления знают про другие представления в сценарии;

## Решение с применением AppCoordinator

Поток управления и данных:

||<->|ListViewController|
|-|-|-|
|Coordinator|<->|DetailsViewController|
||<->|EditorViewController|


```swift
class Coordinator, EditorViewControllerDelegate {
	let sceneViewController = UINavigationController()
	let parent: ParentCoordinator

	var data: [Entity] = []
	var selectedEntity: Entity?

	func start() {
		let list = listViewController()
		sceneViewController.pushViewController(list, animated: true)
		parent.sceneViewController.present(sceneViewController, animated: true, completion: nil)

		DataService.shared.loadData { newData in
			self.data = newData
			list.update(using: newData)
		}
	}

	func stop() {
		parent.sceneViewController.dismiss(animated: true, completion: nil)
	}

	func listViewController() -> ListViewController {
		let controller = // create
		controller.coordinator = self
		return controller
	}

	func presentDetails(of entity: Entity) {
		selectedEntity = entity

		let details = detailsViewController()
		details.data = entity
		sceneViewController.pushViewController(list, animated: true)
	}

	func editProperty() {
		guard let entity = seletedEntity else { return }
		
		let editor = editorViewController()
		editor.value = entity
		editor.delegate = self
		sceneViewController.pushViewController(editor, animated: true)	
	}

	func editorViewController(_ sender: EditorViewController, didChangeValue newValue: Value) {
    	selectedEntity.property = newValue
    	if let details = presentedDetailsViewController() {
    		details.update(using: selectedEntity)
    	}
    	if let list = presentedListViewController() {
    		list.update(using: data)
    	}

    	sceneViewController.popViewController(animated: true)
    }

    func goToList() {
    	sceneViewController.popToRootViewController(animated: true)
    }
}

class ListViewController: UIViewController {
	var coordinator: Coordinator!

	var data: [Entity] = []

	func update(using data: [Entity]) {
		self.data = data
		tableView.reloadData()
	}

	func tableView(tableView: UITableView, didSelectItemAt indexPath: IndexPath) {
		coordinator.presentDetails(of: data[indexPath.row])
	}
}

class DetailsViewControllre: UIViewController {
	var coordinator: Coordinator!

	var data: Entity!

	func update(using data: Entity) {
		self.data = data
		updateViews()
	}

	func fieldTapped(_ sender: AnyObject?) {
		coordinator.editProperty()
	}
}
```