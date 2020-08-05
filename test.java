public class Test{

	class Node{
		Node left;
		Node right;
		int val;

		public Node(int val){
			this.val = val;
		}
	}

    
	public void mergeSort(int[] arr){
		if(arr.length == 0) return;

		int[] aux = new int[arr.length];
		sort(arr,aux,0,arr.length-1);
	}

	public void sort(int[] arr,int[] aux,int lo,int hi){
		if(lo>=hi) return;

		int mid = lo+(hi-lo)/2;
		sort(arr,aux,lo,mid);
		sort(arr,aux,mid+1,hi);
		merge(arr,aux,lo,mid,hi);
	}

	public void merge(int[] arr,int[] aux,int lo,int mid,int hi){

		for(int k=lo;k<=hi;k++){
			aux[k] = arr[k];
		}

		int i = lo,j = mid+1
		for(int k=lo;k<=hi;k++){

			if(i>mid)       arr[k] = aux[j++];
			else(j<mid)     arr[k] = aux[i++];
			else(aux[j]<aux[i]) arr[k] = aux[j++];
			else                arr[k] = aux[i++];
		}
	}

}