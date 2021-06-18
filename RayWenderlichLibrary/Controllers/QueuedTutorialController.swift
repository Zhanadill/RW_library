/// These materials have been reviewed and are updated as of September, 2020
///
/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
///

import UIKit

class QueuedTutorialController: UIViewController {
    
  //нужен для настройки секции для  collectionView
  enum Section {
     case main
  }

  //нужно чтобы вывести день  добавления урока в формате month-date
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
  }()
  
  @IBOutlet var deleteButton: UIBarButtonItem!
  @IBOutlet var updateButton: UIBarButtonItem!
  @IBOutlet var applyUpdatesButton: UIBarButtonItem!
  @IBOutlet weak var collectionView: UICollectionView!
    
  //указали секции и обьекты collectionView
  var dataSource: UICollectionViewDiffableDataSource<Section, Tutorial>!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  //we set nav-bar and added Edit button programmatically, also we set collectionView
  private func setupView() {
    self.title = "Queue"
    navigationItem.leftBarButtonItem = editButtonItem
    navigationItem.rightBarButtonItem = nil
    
    collectionView.collectionViewLayout = configureCollectionViewLayout()
    configureDataSource()
  }
    
    //это мы вызываем в viewWillAppear чтобы обьекты появлялись сразу же после переключения на QueueVC
    //если бы это прописали в viewDidLoad это функция вызывалась бы единожды
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSnapshot()
    }
}

// MARK: - Queue Events -

extension QueuedTutorialController {
  //Настройки edit-buttona
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    //В зависимости от выбранного режима Edit button-a мы скрываем какие-то обьекты nav-bara и делаем так чтобы другие обьекты появлялись
    if isEditing {
      navigationItem.rightBarButtonItems = nil
      navigationItem.rightBarButtonItem = deleteButton
    } else {
      navigationItem.rightBarButtonItem = nil
      navigationItem.rightBarButtonItems = [self.applyUpdatesButton, self.updateButton]
    }

    //сделали так чтобы можно выбирать несколько обьектов когда будем находится в режиме Edit
    collectionView.allowsMultipleSelection = true
    //сделали так чтобы cell-ы можно было выбирать и когда выйдем из режима Edit все выбранные нами обьекты деселектелись
    collectionView.indexPathsForVisibleItems.forEach { indexPath in
      guard let cell = collectionView.cellForItem(at: indexPath) as? QueueCell else { return }
      cell.isEditing = isEditing
      
      if !isEditing {
        cell.isSelected = false
      }
    }
  }

    
  //При нажатии на delete button (который расположен на nav-bare) удаляем все выбранные файлы и выходим из режима Edit
  @IBAction func deleteSelectedItems() {
    guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else { return }
    let tutorials = selectedIndexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
    
    var currentSnapshot = dataSource.snapshot()
    currentSnapshot.deleteItems(tutorials)
    dataSource.apply(currentSnapshot, animatingDifferences: true)
    
    isEditing.toggle()
  }
    

  @IBAction func triggerUpdates() {
  }

    
  @IBAction func applyUpdates() {
  }
}



// MARK: - Collection View -
//Задали размеры для item group section of CollectionView
//Также задали constraints для QueueCell в Main.storyboard
extension QueuedTutorialController {
  func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(149))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    return UICollectionViewCompositionalLayout(section: section)
  }
}



// MARK: - Diffable Data Source -
//Настроили DataSource
extension QueuedTutorialController {
  //присвоили cell-y определенные значения
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Tutorial>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, tutorial: Tutorial) in
      
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QueueCell.reuseIdentifier, for: indexPath) as? QueueCell else {
        return nil
      }
      
      cell.titleLabel.text = tutorial.title
      cell.thumbnailImageView.image = tutorial.image
      cell.thumbnailImageView.backgroundColor = tutorial.imageBackgroundColor
      cell.publishDateLabel.text = tutorial.formattedDate(using: self.dateFormatter)
      
      return cell
    }
  }
  
    
  //в качестве данных рассматриваем лишь массив туториалов у которых переменная isQueued указана каk true
  func configureSnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Tutorial>()
    snapshot.appendSections([.main])
    
    let queuedTutorials = DataSource.shared.tutorials.flatMap { $0.queuedTutorials }
    snapshot.appendItems(queuedTutorials)
    
    dataSource.apply(snapshot, animatingDifferences: true)
  }
}
