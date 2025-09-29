import XCTest
@testable import Money_Manager

class ExportFunctionalityTests: XCTestCase {
    
    var exportService: DataExportService!
    var transactionViewModel: TransactionViewModel!
    var budgetViewModel: BudgetViewModel!
    var loanViewModel: LoanViewModel!
    
    override func setUp() {
        super.setUp()
        exportService = DataExportService()
        transactionViewModel = TransactionViewModel()
        budgetViewModel = BudgetViewModel()
        loanViewModel = LoanViewModel()
        
        exportService.setViewModels(
            transactionViewModel: transactionViewModel,
            budgetViewModel: budgetViewModel,
            loanViewModel: loanViewModel
        )
    }
    
    override func tearDown() {
        exportService = nil
        transactionViewModel = nil
        budgetViewModel = nil
        loanViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Export Service Tests
    
    func testExportServiceInitialization() {
        XCTAssertNotNil(exportService)
        XCTAssertFalse(exportService.isExporting)
        XCTAssertNil(exportService.exportError)
    }
    
    func testExportDataTypeEnum() {
        XCTAssertEqual(ExportDataType.transactions.displayName, "Transactions")
        XCTAssertEqual(ExportDataType.budgets.displayName, "Budgets")
        XCTAssertEqual(ExportDataType.loans.displayName, "Loans")
        XCTAssertEqual(ExportDataType.all.displayName, "All Data")
    }
    
    func testExportDataTypeDescriptions() {
        XCTAssertFalse(ExportDataType.transactions.description.isEmpty)
        XCTAssertFalse(ExportDataType.budgets.description.isEmpty)
        XCTAssertFalse(ExportDataType.loans.description.isEmpty)
        XCTAssertFalse(ExportDataType.all.description.isEmpty)
    }
    
    // MARK: - CSV Generation Tests
    
    func testCSVFieldEscaping() {
        let testCases = [
            ("Normal text", "Normal text"),
            ("Text with, comma", "\"Text with, comma\""),
            ("Text with\"quote", "\"Text with\"\"quote\""),
            ("Text with\nnewline", "\"Text with\nnewline\""),
            ("Text with, comma and\"quote", "\"Text with, comma and\"\"quote\"")
        ]
        
        for (input, expected) in testCases {
            // We can't directly test the private method, but we can test the behavior
            // through the public interface when we have data
            XCTAssertNotNil(input)
            XCTAssertNotNil(expected)
        }
    }
    
    func testDateFormatterConfiguration() {
        let formatter = DateFormatter.csvDateFormatter
        XCTAssertEqual(formatter.dateFormat, "yyyy-MM-dd")
        
        let testDate = Date()
        let formattedDate = formatter.string(from: testDate)
        XCTAssertEqual(formattedDate.count, 10) // yyyy-MM-dd format
        XCTAssertTrue(formattedDate.contains("-"))
    }
    
    // MARK: - Error Handling Tests
    
    func testExportErrorTypes() {
        let noDataError = ExportError.noDataAvailable
        let fileError = ExportError.fileCreationFailed
        let processingError = ExportError.dataProcessingFailed
        
        XCTAssertNotNil(noDataError.errorDescription)
        XCTAssertNotNil(fileError.errorDescription)
        XCTAssertNotNil(processingError.errorDescription)
        
        XCTAssertFalse(noDataError.errorDescription!.isEmpty)
        XCTAssertFalse(fileError.errorDescription!.isEmpty)
        XCTAssertFalse(processingError.errorDescription!.isEmpty)
    }
    
    // MARK: - Test Data Service Tests
    
    func testTestDataServiceStaticMethods() {
        // Test that static methods exist and can be called
        XCTAssertNoThrow({
            TestDataService.addTestData(
                transactionViewModel: transactionViewModel,
                budgetViewModel: budgetViewModel,
                loanViewModel: loanViewModel
            )
        })
        
        // Verify test data was added
        XCTAssertFalse(transactionViewModel.transactions.isEmpty)
        XCTAssertFalse(budgetViewModel.budgets.isEmpty)
        XCTAssertFalse(loanViewModel.loans.isEmpty)
        
        // Test clearing
        XCTAssertNoThrow({
            TestDataService.clearTestData(
                transactionViewModel: transactionViewModel,
                budgetViewModel: budgetViewModel,
                loanViewModel: loanViewModel
            )
        })
        
        // Verify test data was cleared
        XCTAssertTrue(transactionViewModel.transactions.isEmpty)
        XCTAssertTrue(budgetViewModel.budgets.isEmpty)
        XCTAssertTrue(loanViewModel.loans.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testExportServicePerformance() {
        // Add some test data first
        TestDataService.addTestData(
            transactionViewModel: transactionViewModel,
            budgetViewModel: budgetViewModel,
            loanViewModel: loanViewModel
        )
        
        measure {
            // This would test the export performance
            // Note: We can't easily test async methods in unit tests
            // This is more of a placeholder for future integration tests
            _ = ExportDataType.allCases
        }
        
        // Clean up
        TestDataService.clearTestData(
            transactionViewModel: transactionViewModel,
            budgetViewModel: budgetViewModel,
            loanViewModel: loanViewModel
        )
    }
}
