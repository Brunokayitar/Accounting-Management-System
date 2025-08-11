import { useState, useCallback } from "react";
import { Link, useNavigate } from "react-router-dom";
import { 
  ArrowLeft, 
  Plus, 
  Trash2, 
  Calculator, 
  Save, 
  Send, 
  Building2,
  User,
  FileText,
  AlertCircle
} from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { Alert, AlertDescription } from "@/components/ui/alert";

interface TaxCode {
  id: string;
  name: string;
  rate: number;
  type: "VAT" | "WHT" | "EXEMPT";
  description: string;
}

interface InvoiceLineItem {
  id: string;
  description: string;
  quantity: number;
  unitPrice: number;
  taxCode: string;
  amount: number;
  vatAmount: number;
  whtAmount: number;
}

interface Customer {
  id: string;
  name: string;
  vatNumber?: string;
  address: string;
  entityType: "individual" | "company" | "government";
}

const TAX_CODES: TaxCode[] = [
  { id: "VAT_18", name: "VAT 18%", rate: 18, type: "VAT", description: "Standard VAT rate for Rwanda" },
  { id: "VAT_0", name: "VAT 0%", rate: 0, type: "VAT", description: "Zero-rated VAT" },
  { id: "VAT_EXEMPT", name: "VAT Exempt", rate: 0, type: "EXEMPT", description: "VAT exempt goods/services" },
  { id: "WHT_15", name: "WHT 15%", rate: 15, type: "WHT", description: "Standard withholding tax rate" },
  { id: "WHT_5", name: "WHT 5%", rate: 5, type: "WHT", description: "Reduced withholding tax rate" },
];

const SAMPLE_CUSTOMERS: Customer[] = [
  { 
    id: "1", 
    name: "Kigali Tech Solutions Ltd", 
    vatNumber: "VAT-001234567", 
    address: "KG 123 St, Kigali",
    entityType: "company"
  },
  { 
    id: "2", 
    name: "Rwanda Bank Ltd", 
    vatNumber: "VAT-098765432", 
    address: "KN 456 Ave, Kigali",
    entityType: "company"
  },
  { 
    id: "3", 
    name: "Ministry of ICT", 
    address: "Government Ave, Kigali",
    entityType: "government"
  },
];

export default function CreateInvoice() {
  const navigate = useNavigate();
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);
  const [invoiceNumber, setInvoiceNumber] = useState("INV-2024-003");
  const [invoiceDate, setInvoiceDate] = useState(new Date().toISOString().split('T')[0]);
  const [dueDate, setDueDate] = useState(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]);
  const [currency, setCurrency] = useState("RWF");
  const [notes, setNotes] = useState("");
  
  const [lineItems, setLineItems] = useState<InvoiceLineItem[]>([
    {
      id: "1",
      description: "",
      quantity: 1,
      unitPrice: 0,
      taxCode: "VAT_18",
      amount: 0,
      vatAmount: 0,
      whtAmount: 0
    }
  ]);

  const calculateLineItem = useCallback((item: InvoiceLineItem): InvoiceLineItem => {
    const taxCode = TAX_CODES.find(tc => tc.id === item.taxCode);
    if (!taxCode) return item;

    const subtotal = item.quantity * item.unitPrice;
    let vatAmount = 0;
    let whtAmount = 0;

    if (taxCode.type === "VAT") {
      vatAmount = (subtotal * taxCode.rate) / 100;
    } else if (taxCode.type === "WHT") {
      whtAmount = (subtotal * taxCode.rate) / 100;
    }

    return {
      ...item,
      amount: subtotal,
      vatAmount,
      whtAmount
    };
  }, []);

  const updateLineItem = (id: string, field: keyof InvoiceLineItem, value: any) => {
    setLineItems(items => 
      items.map(item => {
        if (item.id === id) {
          const updated = { ...item, [field]: value };
          return calculateLineItem(updated);
        }
        return item;
      })
    );
  };

  const addLineItem = () => {
    const newItem: InvoiceLineItem = {
      id: (lineItems.length + 1).toString(),
      description: "",
      quantity: 1,
      unitPrice: 0,
      taxCode: "VAT_18",
      amount: 0,
      vatAmount: 0,
      whtAmount: 0
    };
    setLineItems([...lineItems, newItem]);
  };

  const removeLineItem = (id: string) => {
    if (lineItems.length > 1) {
      setLineItems(items => items.filter(item => item.id !== id));
    }
  };

  const calculateTotals = () => {
    const subtotal = lineItems.reduce((sum, item) => sum + item.amount, 0);
    const totalVAT = lineItems.reduce((sum, item) => sum + item.vatAmount, 0);
    const totalWHT = lineItems.reduce((sum, item) => sum + item.whtAmount, 0);
    const total = subtotal + totalVAT - totalWHT;

    return { subtotal, totalVAT, totalWHT, total };
  };

  const formatRWF = (amount: number) => {
    return new Intl.NumberFormat('en-RW', {
      style: 'currency',
      currency: 'RWF',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount);
  };

  const handleSave = () => {
    // TODO: Implement save logic
    console.log("Saving invoice...");
  };

  const handleSend = () => {
    // TODO: Implement send logic
    console.log("Sending invoice...");
  };

  const totals = calculateTotals();

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="flex h-16 items-center justify-between">
            <div className="flex items-center space-x-4">
              <Link to="/" className="flex items-center space-x-2 text-muted-foreground hover:text-foreground">
                <ArrowLeft className="h-4 w-4" />
                <span>Back to Dashboard</span>
              </Link>
              <Separator orientation="vertical" className="h-6" />
              <div className="flex items-center space-x-2">
                <Building2 className="h-6 w-6 text-primary" />
                <span className="font-semibold">Create Invoice</span>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <Button variant="outline" onClick={handleSave}>
                <Save className="mr-2 h-4 w-4" />
                Save Draft
              </Button>
              <Button onClick={handleSend}>
                <Send className="mr-2 h-4 w-4" />
                Send Invoice
              </Button>
            </div>
          </div>
        </div>
      </header>

      <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8 py-8">
        <div className="space-y-8">
          {/* Invoice Header */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <FileText className="h-5 w-5" />
                <span>Invoice Details</span>
              </CardTitle>
              <CardDescription>
                Basic invoice information and customer selection
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid gap-4 md:grid-cols-3">
                <div className="space-y-2">
                  <Label htmlFor="invoice-number">Invoice Number</Label>
                  <Input
                    id="invoice-number"
                    value={invoiceNumber}
                    onChange={(e) => setInvoiceNumber(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="invoice-date">Invoice Date</Label>
                  <Input
                    id="invoice-date"
                    type="date"
                    value={invoiceDate}
                    onChange={(e) => setInvoiceDate(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="due-date">Due Date</Label>
                  <Input
                    id="due-date"
                    type="date"
                    value={dueDate}
                    onChange={(e) => setDueDate(e.target.value)}
                  />
                </div>
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="customer">Customer</Label>
                  <Select value={selectedCustomer?.id || ""} onValueChange={(value) => {
                    const customer = SAMPLE_CUSTOMERS.find(c => c.id === value);
                    setSelectedCustomer(customer || null);
                  }}>
                    <SelectTrigger>
                      <SelectValue placeholder="Select a customer" />
                    </SelectTrigger>
                    <SelectContent>
                      {SAMPLE_CUSTOMERS.map((customer) => (
                        <SelectItem key={customer.id} value={customer.id}>
                          <div className="flex items-center space-x-2">
                            {customer.entityType === "company" ? (
                              <Building2 className="h-4 w-4" />
                            ) : (
                              <User className="h-4 w-4" />
                            )}
                            <span>{customer.name}</span>
                          </div>
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  {selectedCustomer && (
                    <div className="mt-2 p-3 bg-muted rounded-md">
                      <p className="text-sm font-medium">{selectedCustomer.name}</p>
                      {selectedCustomer.vatNumber && (
                        <p className="text-xs text-muted-foreground">VAT: {selectedCustomer.vatNumber}</p>
                      )}
                      <p className="text-xs text-muted-foreground">{selectedCustomer.address}</p>
                      <Badge variant="outline" className="mt-1">
                        {selectedCustomer.entityType}
                      </Badge>
                    </div>
                  )}
                </div>
                <div className="space-y-2">
                  <Label htmlFor="currency">Currency</Label>
                  <Select value={currency} onValueChange={setCurrency}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="RWF">Rwanda Franc (RWF)</SelectItem>
                      <SelectItem value="USD">US Dollar (USD)</SelectItem>
                      <SelectItem value="EUR">Euro (EUR)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Line Items */}
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle className="flex items-center space-x-2">
                    <Calculator className="h-5 w-5" />
                    <span>Invoice Line Items</span>
                  </CardTitle>
                  <CardDescription>
                    Add products/services with Rwanda tax calculations
                  </CardDescription>
                </div>
                <Button onClick={addLineItem} size="sm">
                  <Plus className="mr-2 h-4 w-4" />
                  Add Line
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {lineItems.map((item, index) => (
                  <div key={item.id} className="grid gap-4 md:grid-cols-12 items-end p-4 border border-border rounded-lg">
                    <div className="md:col-span-4">
                      <Label htmlFor={`description-${item.id}`}>Description</Label>
                      <Input
                        id={`description-${item.id}`}
                        placeholder="Product or service description"
                        value={item.description}
                        onChange={(e) => updateLineItem(item.id, "description", e.target.value)}
                      />
                    </div>
                    <div className="md:col-span-1">
                      <Label htmlFor={`quantity-${item.id}`}>Qty</Label>
                      <Input
                        id={`quantity-${item.id}`}
                        type="number"
                        min="0"
                        step="0.01"
                        value={item.quantity}
                        onChange={(e) => updateLineItem(item.id, "quantity", parseFloat(e.target.value) || 0)}
                      />
                    </div>
                    <div className="md:col-span-2">
                      <Label htmlFor={`unit-price-${item.id}`}>Unit Price</Label>
                      <Input
                        id={`unit-price-${item.id}`}
                        type="number"
                        min="0"
                        step="0.01"
                        value={item.unitPrice}
                        onChange={(e) => updateLineItem(item.id, "unitPrice", parseFloat(e.target.value) || 0)}
                      />
                    </div>
                    <div className="md:col-span-2">
                      <Label htmlFor={`tax-code-${item.id}`}>Tax Code</Label>
                      <Select value={item.taxCode} onValueChange={(value) => updateLineItem(item.id, "taxCode", value)}>
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {TAX_CODES.map((code) => (
                            <SelectItem key={code.id} value={code.id}>
                              <div className="flex items-center justify-between w-full">
                                <span>{code.name}</span>
                                <Badge variant="outline" className="ml-2">
                                  {code.rate}%
                                </Badge>
                              </div>
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="md:col-span-2">
                      <Label>Amount</Label>
                      <div className="text-sm space-y-1">
                        <p className="font-medium">{formatRWF(item.amount)}</p>
                        {item.vatAmount > 0 && (
                          <p className="text-xs text-muted-foreground">VAT: {formatRWF(item.vatAmount)}</p>
                        )}
                        {item.whtAmount > 0 && (
                          <p className="text-xs text-muted-foreground">WHT: -{formatRWF(item.whtAmount)}</p>
                        )}
                      </div>
                    </div>
                    <div className="md:col-span-1">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => removeLineItem(item.id)}
                        disabled={lineItems.length === 1}
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                ))}
              </div>

              {/* Tax Information Alert */}
              <Alert className="mt-6">
                <AlertCircle className="h-4 w-4" />
                <AlertDescription>
                  <strong>Rwanda Tax Information:</strong> VAT at 18% is automatically calculated. 
                  Withholding tax (WHT) applies to certain payments as per RRA regulations. 
                  Government entities may be exempt from certain taxes.
                </AlertDescription>
              </Alert>
            </CardContent>
          </Card>

          {/* Invoice Summary */}
          <Card>
            <CardHeader>
              <CardTitle>Invoice Summary</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="notes">Notes</Label>
                    <Textarea
                      id="notes"
                      placeholder="Additional notes or terms..."
                      value={notes}
                      onChange={(e) => setNotes(e.target.value)}
                      rows={4}
                    />
                  </div>
                  <div className="space-y-3">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Subtotal:</span>
                      <span className="font-medium">{formatRWF(totals.subtotal)}</span>
                    </div>
                    {totals.totalVAT > 0 && (
                      <div className="flex justify-between">
                        <span className="text-muted-foreground">VAT (18%):</span>
                        <span className="font-medium">{formatRWF(totals.totalVAT)}</span>
                      </div>
                    )}
                    {totals.totalWHT > 0 && (
                      <div className="flex justify-between">
                        <span className="text-muted-foreground">WHT:</span>
                        <span className="font-medium text-destructive">-{formatRWF(totals.totalWHT)}</span>
                      </div>
                    )}
                    <Separator />
                    <div className="flex justify-between text-lg font-bold">
                      <span>Total:</span>
                      <span>{formatRWF(totals.total)}</span>
                    </div>
                    <div className="text-xs text-muted-foreground">
                      All amounts in {currency}
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
